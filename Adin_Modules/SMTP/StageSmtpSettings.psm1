#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.deploy@example.ru"
$global:To = "admins@example.ru", " n.terentieva@example.ru", "s.udina@example.ru", "support@example.ru"
$global:subject = "STAGE: Auto Deploy Mailer."
$global:SMTPServer = "md2.example.loc"
$global:SMTPUsername = "auto.deploy@example.ru"
$global:SMTPPassword = "7539148620qQ"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.deploy@example.ru"
$To = "admins@example.ru", " n.terentieva@example.ru", "s.udina@example.ru", "support@example.ru"
$subject = "STAGE: Auto Deploy Mailer."
$SMTPServer = "md2.example.loc"
$SMTPUsername = "auto.deploy@example.ru"
$SMTPPassword = "7539148620qQ"
$SMTPPort = "25"
$emailattachment = $logfile.path
#return $global:From, $global:To, $global:subject, $global:SMTPServer, $global:SMTPUsername, $global:SMTPPassword, $global:SMTPPort, $global:emailattachment