#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$global:From = "auto.report@example.ru"
$global:To = "deploy@example.ru"
$global:subject = "TEST AUTO UPDATE: Deploy Mailer"
$global:SMTPServer = "md2.example.loc"
$global:SMTPUsername = "auto.report@example.ru"
$global:SMTPPassword = "7539148620qQ"
$global:SMTPPort = "25"
$global:emailattachment = $logfile.path

$From = "auto.report@example.ru"
$To = "deploy@example.ru"
$subject = "TEST AUTO UPDATE: Deploy Mailer"
$SMTPServer = "md2.example.loc"
$SMTPUsername = "auto.report@example.ru"
$SMTPPassword = "7539148620qQ"
$SMTPPort = "25"
$emailattachment = $logfile.path