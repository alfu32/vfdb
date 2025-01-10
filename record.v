module vfdb

import crypto.md5
import time
import strconv

fn first_32_bytes(input string) [32]u8 {
	mut result := [32]u8{} // Initialize a [32]u8 array with zeroes
	bytes := input.bytes() // Get the bytes of the string

	// Copy the first 32 bytes (or less if input is shorter)
	for i in 0 .. bytes.len {
		if i >= 32 {
			break
		}
		result[i] = bytes[i]
	}

	return result
}

@[heap]
pub struct RecordProducer {
pub mut:
	name             string
	hashing_function fn (buf []u8) string = fn (buf []u8) string {
		return md5.sum([]).map('${it:02x}').join('')
	}
}

pub fn RecordProducer.md5() &RecordProducer {
	return &RecordProducer{
		name:             'default.md5'
		hashing_function: fn (buf []u8) string {
			return md5.hexhash(buf.str())
		}
	}
}

pub fn (self RecordProducer) getid(buf []u8) string {
	return self.hashing_function(buf)
}

pub fn (self RecordProducer) record_is_empty(record &Record) bool {
	return self.hashing_function([]u8{}) == record.id
}

pub fn (self RecordProducer) new_record_from_buffer(buf []u8, start_position u64) &Record {
	mut r := Record.new()
	r.id = md5.hexhash(buf.str())
	r.start = start_position
	r.end = start_position + u64(buf.len)
	return r
}

@[heap]
pub struct Record {
pub mut:
	id        string
	timestamp time.Time
	start     u64
	end       u64
}

pub fn Record.new() &Record {
	mut r := &Record{}
	r.timestamp = time.now()
	return r
}

pub fn (r Record) clone() Record {
	return Record{
		id:        r.id
		timestamp: r.timestamp
		start:     r.start
		end:       r.end
	}
}

pub fn (r Record) copy() &Record {
	return &Record{
		id:        r.id
		timestamp: time.now()
		start:     r.start
		end:       r.end
	}
}

pub fn (mut r Record) move(dir i32) &Record {
	r.start += u64(dir)
	r.end += u64(dir)
	return r
}

pub fn (mut r Record) moved(dir i32) Record {
	mut r2 := r.clone()
	r2.move(dir)
	return r2
}

pub fn (mut r Record) is_deleted() bool {
	return r.start == 0 && r.end == 0
}

// Method to convert the struct to a fixed-width string
pub fn (r Record) to_string() string {
	// Format timestamp as ISO8601
	timestamp_str := '${r.timestamp.unix_milli():x}'
	// Format journal_start and journal_end as zero-padded hexadecimal
	journal_start_hex := '${r.start:x}'
	journal_end_hex := '${r.end:x}'

	return '${r.id} ${timestamp_str} ${journal_start_hex} ${journal_end_hex}'
}

// Static method to parse a string into a Record struct
pub fn record_from_string(input string) !Record {
	// Split the input string by spaces
	parts := input.split(' ')
	if parts.len != 4 {
		return error('Invalid input format: expected 4 parts, got ${parts.len}')
	}

	// Parse timestamp as hexadecimal
	timestamp_millis := strconv.parse_int(parts[1], 16, 64) or {
		return error('Invalid timestamp format: ${parts}[0]')
	}
	timestamp_t := time.unix_microsecond(i64(timestamp_millis / 1000), int((timestamp_millis % 1000) * 1_000_000))

	// Parse journal_start as hexadecimal
	journal_start := strconv.parse_uint(parts[2], 16, 64) or {
		return error('Invalid journal_start format: ${parts}[1]')
	}

	// Parse journal_end as hexadecimal
	journal_end := strconv.parse_uint(parts[3], 16, 64) or {
		return error('Invalid journal_end format: ${parts}[2]')
	}

	// The last part is the ID
	id := parts[0]

	// Return the constructed Record
	return Record{
		id:        id
		timestamp: timestamp_t
		start:     journal_start
		end:       journal_end
	}
}
