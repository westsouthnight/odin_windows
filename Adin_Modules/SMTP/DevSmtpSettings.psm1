#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.deploy@example.ru"
$global:To = "admins@example.ru", "a.igumnov@example.ru"
$global:subject = "DEV: Auto Deploy Mailer."
$global:SMTPServer = "md2.example.loc"
$global:SMTPUsername = "auto.deploy@example.ru"
$global:SMTPPassword = "7539148620qQ"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.deploy@example.ru"
$To = "admins@example.ru", "a.igumnov@example.ru"
$subject = "DEV: Auto Deploy Mailer."
$SMTPServer = "md2.example.loc"
$SMTPUsername = "auto.deploy@example.ru"
$SMTPPassword = "7539148620qQ"
$SMTPPort = "25"
$emailattachment = $logfile.path