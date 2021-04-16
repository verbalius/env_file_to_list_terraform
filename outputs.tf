output "env_list" {
  value = [
    for line in compact(split("\n", replace(file(var.env_file_path), "/#.*/", ""))) :
    zipmap(
      [
        "name",
        "value"
      ],
      [
        element(regex("^(\\w+)=", line), 1),              #first part of VAR=VAL
        element(regex("^\\w+=\"??'??([^\"']+)", line), 1) #second part of VAR=VAL
      ]
    )
  ]
}
