module vfdb

import time
import crypto.md5

pub fn test_new_record() {
	r := Record{}
	println(r)
}

pub fn test_new_empty() {
	rp := RecordProducer{}
	p := []u8{}
	println(''.bytes())
	id := rp.getid(''.bytes())
	println(rp)
	println(id)
	println(md5.hexhash(''))
	println(md5.sum([]))
	println(md5.sum([]).map('${it:02x}').join(''))
}

pub fn test_new_record_producer() {
	r := RecordProducer{}
	println(r)
}

pub fn test_new_record_from_buffer_with_producer() {
	rp := RecordProducer{}
	r := rp.new_record_from_buffer('hello'.bytes(), 0)
	println(r)
}

pub fn test_id_from_default_record_producer() {
	rp := RecordProducer{}
	r := rp.getid('hello'.bytes())
	println(r)
}

pub fn test_record_to_string() {
	rp := RecordProducer{}
	r := rp.new_record_from_buffer('hello'.bytes(), 0)
	// Example usage
	record := Record{
		id:        r.id
		timestamp: time.now()
		start:     12345678
		end:       87654321
	}

	stringified := record.to_string()
	println('Stringified: ${stringified}')
}

pub fn test_record_from_string() {
	stringified := '5d41402abc4b2a76b9719d911017c592 194502b51d3 bc614e 5397fb1'
	println('Stringified: ${stringified}')
	parsed_record := record_from_string(stringified) or {
		eprintln('Failed to parse record: ${err}')
		return
	}
	println('Parsed Record: ${parsed_record}')
}
