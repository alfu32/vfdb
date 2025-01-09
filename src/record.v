module main

pub struct Record{
pub mut:
	id byte[32]
	journal_start u64
	journal_end u64
}

pub fn Record.new() &Record {
    return &Record{}
}

pub fn Record.from_buffer() &Record {
    mut r := &Record{}

}

