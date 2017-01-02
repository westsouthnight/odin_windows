#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.report@example.ru"
$global:To = "deploy@example.ru"
$global:subject = "TEST AUTO UPDATE: Deploy Mailer"
$global:SMTPServer = "mail2.example.loc"
$global:SMTPUsername = "auto.report@example.ru"
$global:SMTPPassword = "EXAMPLE_TXT"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.report@example.ru"
$To = "deploy@example.ru"
$subject = "TEST AUTO UPDATE: Deploy Mailer"
$SMTPServer = "mail2.example.loc"
$SMTPUsername = "auto.report@example.ru"
$SMTPPassword = "EXAMPLE_TXT"
$SMTPPort = "25"
$emailattachment = $logfile.path