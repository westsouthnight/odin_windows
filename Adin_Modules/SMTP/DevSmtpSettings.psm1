#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.deploy@example.ru"
$global:To = "admins@example.ru", "robot_ai@example.ru"
$global:subject = "DEV: Auto Deploy Mailer."
$global:SMTPServer = "mail2.example.loc"
$global:SMTPUsername = "auto.deploy@example.ru"
$global:SMTPPassword = "EXAMPLE_TXT"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.deploy@example.ru"
$To = "admins@example.ru", "robot_ai@example.ru"
$subject = "DEV: Auto Deploy Mailer."
$SMTPServer = "mail2.example.loc"
$SMTPUsername = "auto.deploy@example.ru"
$SMTPPassword = "EXAMPLE_TXT"
$SMTPPort = "25"
$emailattachment = $logfile.path