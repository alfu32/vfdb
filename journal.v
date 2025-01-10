module vfdb

import os

pub struct Journal {
pub:
	path string = 'default'
pub mut:
	record_producer &RecordProducer
	records         []Record
	journal         string
	data            string
}

pub fn journal_new(record_producer &RecordProducer, path string) !&Journal {
	mut jf := &Journal{
		records:         []
		path:            path
		record_producer: record_producer
	}
	jf.journal = '${path}.journal'
	jf.data = '${path}.data'
	jf.open() or { return err }
	return jf
}

pub fn (mut j Journal) open() !Journal {
	mut jf := os.open(j.journal) or {
		// println("${j.path} could not open ${j.journal} for reading \n Error ${err}")
		os.create(j.journal) or {
			return error('${j.journal} does not exist,  could not create ${j.journal} for reading \n Error ${err}')
		}
	}
	jf.close()
	mut journal_contents := os.read_file(j.journal) or {
		// println("${j.path} could not read ${j.journal} \n Error ${err}")
		return error('${j.path} could not read ${j.journal} \n Error ${err}')
	}
	for _, line in journal_contents.split_into_lines() {
		j.records << (record_from_string(line)!)
		// println(line)
	}
	return j
}

pub fn (mut j Journal) insert(buf []u8) !&Record {
	// Open the file in append mode
	mut journal_file := os.open_append(j.journal) or {
		return error('Failed to open journal: ${err}')
	}
	defer {
		journal_file.close()
	}
	mut data_file := os.open_append(j.data) or { return error('Failed to open data: ${err}') }
	defer {
		data_file.close()
	}

	// Get the current file size (seek position before writing)
	start_position := os.file_size(j.data)
	// Write the buffer to the file
	data_file.write(buf) or { return error('Failed to write buffer to data: ${err}') }

	// Create a Record from the buffer
	record := j.record_producer.new_record_from_buffer(buf, start_position)

	journal_file.write('${record.to_string()}\n'.bytes()) or {
		return error('Failed to write record to journal: ${err}')
	}
	j.records << record
	return record
}

pub fn (mut j Journal) delete(r &Record) !&Record {
	mut record := r.copy()
	record.start = 0
	record.end = 0
	// Open the file in append mode
	mut journal_file := os.open_append(j.journal) or {
		return error('Failed to open journal: ${err}')
	}
	defer {
		journal_file.close()
	}
	journal_file.write('${record.to_string()}\n'.bytes()) or {
		return error('Failed to write record to journal: ${err}')
	}
	j.records << record
	return record
}

fn (j Journal) count() u64 {
	return u64(j.records.len)
}

fn (j Journal) read_record_content(r &Record) ![]u8 {
	file_path := j.data
	start := r.start
	end := r.end
	// Open the file in read mode
	mut file := os.open(file_path) or { return error('Failed to open file: ${err}') }
	defer {
		file.close()
	}

	// Seek to the starting position
	file.seek(i64(start), .start) or { return error('Failed to seek to start position: ${err}') }

	// Calculate the number of bytes to read
	num_bytes := end - start

	// Read the chunk of bytes
	mut buffer := []u8{len: int(num_bytes)}
	file.read(mut buffer) or { return error('Failed to read bytes: ${err}') }

	return buffer
}

pub fn (mut j Journal) aggregate_all[A](aggregator fn (context A, record &Record, index u64) A, initial_context A) !A {
	mut index := u64(0)
	mut ctx := unsafe { initial_context }
	for r in j.records {
		ctx = aggregator(ctx, r, index)
		index += 1
	}
	return ctx
}
