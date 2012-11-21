BEGIN {
	RS=/\"current_pg\"/;
	FS=/\s/;
}

/\"current_pg\"\>\</ {
	b=$11;
	arr_length = split(b, arr, /\</)
	print arr[1];
}