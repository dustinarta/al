@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.create(
		["""If you've received a message that says that your administrator, or your organization, requires a ""cloud security scan"" of this item, or that Microsoft Defender Antivirus needs to perform a cloud security scan, this is because your system is configured to use Cloud-delivered protection and Automatic sample submission, and you've just opened a file that could be dangerous. The Microsoft Defender cloud service is going to take a quick look at the file and confirm that it's safe before allowing it to proceed. This usually doesn't take very long."""],
		10
	)
	print(sem.keys)
