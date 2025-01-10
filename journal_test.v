module main

import os

fn before_all() {}

fn before_each() {}

fn after_each() {}

pub fn test_journal_create() {
	j := Journal{
		record_producer: &RecordProducer{}
	}
	println(j)
}

pub fn test_journal_new() {
	j := journal_new(RecordProducer{}, 'test_journal_new') or {
		eprintln('failed to init journal')
		&Journal{
			record_producer: &RecordProducer{}
		}
	}
	println(j)
}

pub fn test_journal_open() {
	mut succeeded := true
	os.rm('test_journal_open.journal') or {}
	mut j := journal_new(RecordProducer{}, 'test_journal_open') or {
		eprintln('failed to init journal')
		&Journal{
			record_producer: &RecordProducer{}
		}
	}
	println(j)
	j.open() or {
		println('test_journal_open failed : ${err}')
		succeeded = false
	}
	println(j)
	os.rm('test_journal_open.journal') or {}
	assert succeeded
}

pub fn test_journal_storage() {
	mut succeeded := true
	os.rm('test_journal_open.journal') or {}
	mut j := journal_new(RecordProducer{}, 'test_journal_open') or {
		eprintln('failed to init journal')
		&Journal{
			record_producer: &RecordProducer{}
		}
	}
	println(j)
	j.open() or {
		println('test_journal_open failed : ${err}')
		succeeded = false
	}
	println(j)
	os.rm('test_journal_open.journal') or {}
	assert succeeded
}

pub fn test_journal_insert() {
	mut succeeded := true
	mut error_message := ''
	set_errors := fn [mut succeeded, mut error_message] (err IError) {
		error_message = '${err}'
		succeeded = false
	}
	mut j := journal_new(RecordProducer{}, 'test') or {
		set_errors(err)
		&Journal{
			record_producer: &RecordProducer{}
			path: 'test'
		}
	}
	j.open() or { set_errors(err) }
	r0 := j.insert('record 0'.bytes()) or {
		j.record_producer.new_record_from_buffer('record 0'.bytes(), 0)
	}
	j.insert('record 1'.bytes()) or { set_errors(err) }
	j.insert('record 2'.bytes()) or { set_errors(err) }
	j.insert('record 3'.bytes()) or { set_errors(err) }
	j.delete(r0) or { set_errors(err) }
	for r in j.records {
		println(r)
		println(j.read_record_content(r) or { 'nothing'.bytes() }.bytestr())
	}
	println(error_message)
	assert succeeded
}

pub fn test_journal_iterate() {
	mut succeeded := true
	mut error_message := ''
	set_errors := fn [mut succeeded, mut error_message] (err IError) {
		error_message = '${err}'
		succeeded = false
	}
	mut j := journal_new(RecordProducer{}, 'test') or {
		set_errors(err)
		&Journal{
			record_producer: &RecordProducer{}
			path: 'test'
		}
	}
	j.open() or { set_errors(err) }
	r0 := j.insert('record 0'.bytes()) or {
		set_errors(err)
		j.record_producer.new_record_from_buffer('record 0'.bytes(), 0)
	}
	j.insert('record 1'.bytes()) or { set_errors(err) }
	j.insert('record 2'.bytes()) or { set_errors(err) }
	j.insert('record 3'.bytes()) or { set_errors(err) }
	j.delete(r0) or { set_errors(err) }
	t := j.count()

	content := j.aggregate_all[[]string](fn [j, t] (ctx []string, r &Record, i u64) []string {
		mut nctx := ctx.clone()
		nctx << r.to_string()
		println('[${i + 1:4} / ${t:4}] ${r.id} ${r.timestamp} ${j.read_record_content(r) or {
			'not-found'.bytes()
		}.bytestr()}')
		return nctx
	}, []string{}) or { ['nothing'] }

	println(content)
	println(error_message)
	assert succeeded
}
