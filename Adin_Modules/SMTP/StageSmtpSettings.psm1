#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.deploy@example.ru"
$global:To = "admins@example.ru", " n.terentieva@example.ru", "s.udina@example.ru", "support@example.ru"
$global:subject = "STAGE: Auto Deploy Mailer."
$global:SMTPServer = "mail2.example.loc"
$global:SMTPUsername = "auto.deploy@example.ru"
$global:SMTPPassword = "EXAMPLE_TXT"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.deploy@example.ru"
$To = "admins@example.ru", " n.terentieva@example.ru", "s.udina@example.ru", "support@example.ru"
$subject = "STAGE: Auto Deploy Mailer."
$SMTPServer = "mail2.example.loc"
$SMTPUsername = "auto.deploy@example.ru"
$SMTPPassword = "EXAMPLE_TXT"
$SMTPPort = "25"
$emailattachment = $logfile.path
#return $global:From, $global:To, $global:subject, $global:SMTPServer, $global:SMTPUsername, $global:SMTPPassword, $global:SMTPPort, $global:emailattachment