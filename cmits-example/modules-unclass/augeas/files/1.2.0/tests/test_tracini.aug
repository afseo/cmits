module Test_tracini =
    let lns = Tracini.lns
    test lns get "
# -*- coding: utf-8 -*-

[attachment]
max_size = 262144
render_unsafe_content = false

[browser]
hide_properties = svk:merge

[components]
tracgantt.* = enabled

[gantt-charts]
date_format = %Y/%m/%d
include_summary = true
show_opened = true
summary_length = 32
use_creation_date = true

[header_logo]
alt = Trac
height = 73
link = http://trac.edgewall.com/
src = common/trac_banner.png
width = 236

[intertrac]
z = zarquon
zarquon = zarquon
zarquon.title = Zarquon
zarquon.url = https://one.example.com/projects/zarquon
m = mahershalalhashbaz
mahershalalhashbaz = mahershalalhashbaz
mahershalalhashbaz.title = Mahershalalhashbaz trac
mahershalalhashbaz.url = https://two.example.com/projects/mahershalalhashbaz

[logging]
log_file = trac.log
log_level = DEBUG
log_type = none

[mimeviewer]
enscript_path = enscript
max_preview_size = 262144
php_path = php
tab_width = 8

[notification]
always_notify_owner = true
always_notify_reporter = true
smtp_always_cc = 
smtp_defaultdomain = example.com
smtp_enabled = true
smtp_from = zarquon-trac@example.com
smtp_password = 
smtp_port = 25
smtp_replyto = onewebmaster@example.com
smtp_server = localhost
smtp_user = 

[project]
descr = Zarquon
footer = Visit the Trac open source project at<br /><a href=\"http://trac.edgewall.com/\">http://trac.edgewall.com/</a>
icon = common/trac.ico
name = Zarquon
url = https://one.example.com/projects/zarquon/

[ticket]
default_component = component1
default_milestone = 
default_priority = major
default_type = defect
default_version = 
restrict_owner = false

[ticket-custom]
dependencies = text
dependencies.label = Dependencies
dependencies.value = 
due_assign = text
due_assign.label = Due to assign
due_assign.value = YYYY/MM/DD
due_close = text
due_close.label = Due to close
due_close.value = YYYY/MM/DD
include_gantt = checkbox
include_gantt.label = Include in GanttChart
include_gantt.value = 

[ticket-workflow]
accept = new -> assigned
accept.operations = set_owner_to_self
accept.permissions = TICKET_MODIFY
leave = * -> *
leave.default = 1
leave.operations = leave_status
reassign = new,assigned,reopened -> new
reassign.operations = set_owner
reassign.permissions = TICKET_MODIFY
reopen = closed -> reopened
reopen.operations = del_resolution
reopen.permissions = TICKET_CREATE
resolve = new,assigned,reopened -> closed
resolve.operations = set_resolution
resolve.permissions = TICKET_MODIFY

[timeline]
changeset_show_files = 0
default_daysback = 30
ticket_show_details = false

[trac]
check_auth_ip = true
database = sqlite:db/trac.db
default_charset = iso-8859-15
default_handler = WikiModule
ignore_auth_case = false
mainnav = wiki,timeline,roadmap,browser,tickets,newticket,search
metanav = login,logout,settings,help,about
permission_store = DefaultPermissionStore
repository_dir = /var/www/svn/ftdb
templates_dir = /usr/share/trac/templates

[wiki]
ignore_missing_pages = false
" = (
  {  }
  { "#comment" = "-*- coding: utf-8 -*-" }
  {  }
  { "attachment"
    { "max_size" = "262144" }
    { "render_unsafe_content" = "false" }
    {  }
  }
  { "browser"
    { "hide_properties" = "svk:merge" }
    {  }
  }
  { "components"
    { "tracgantt.*" = "enabled" }
    {  }
  }
  { "gantt-charts"
    { "date_format" = "%Y/%m/%d" }
    { "include_summary" = "true" }
    { "show_opened" = "true" }
    { "summary_length" = "32" }
    { "use_creation_date" = "true" }
    {  }
  }
  { "header_logo"
    { "alt" = "Trac" }
    { "height" = "73" }
    { "link" = "http://trac.edgewall.com/" }
    { "src" = "common/trac_banner.png" }
    { "width" = "236" }
    {  }
  }
  { "intertrac"
    { "z" = "zarquon" }
    { "zarquon" = "zarquon" }
    { "zarquon.title" = "Zarquon" }
    { "zarquon.url" = "https://one.example.com/projects/zarquon" }
    { "m" = "mahershalalhashbaz" }
    { "mahershalalhashbaz" = "mahershalalhashbaz" }
    { "mahershalalhashbaz.title" = "Mahershalalhashbaz trac" }
    { "mahershalalhashbaz.url" = "https://two.example.com/projects/mahershalalhashbaz" }
    {  }
  }
  { "logging"
    { "log_file" = "trac.log" }
    { "log_level" = "DEBUG" }
    { "log_type" = "none" }
    {  }
  }
  { "mimeviewer"
    { "enscript_path" = "enscript" }
    { "max_preview_size" = "262144" }
    { "php_path" = "php" }
    { "tab_width" = "8" }
    {  }
  }
  { "notification"
    { "always_notify_owner" = "true" }
    { "always_notify_reporter" = "true" }
    { "smtp_always_cc" }
    { "smtp_defaultdomain" = "example.com" }
    { "smtp_enabled" = "true" }
    { "smtp_from" = "zarquon-trac@example.com" }
    { "smtp_password" }
    { "smtp_port" = "25" }
    { "smtp_replyto" = "onewebmaster@example.com" }
    { "smtp_server" = "localhost" }
    { "smtp_user" }
    {  }
  }
  { "project"
    { "descr" = "Zarquon" }
    { "footer" = "Visit the Trac open source project at<br /><a href=\"http://trac.edgewall.com/\">http://trac.edgewall.com/</a>" }
    { "icon" = "common/trac.ico" }
    { "name" = "Zarquon" }
    { "url" = "https://one.example.com/projects/zarquon/" }
    {  }
  }
  { "ticket"
    { "default_component" = "component1" }
    { "default_milestone" }
    { "default_priority" = "major" }
    { "default_type" = "defect" }
    { "default_version" }
    { "restrict_owner" = "false" }
    {  }
  }
  { "ticket-custom"
    { "dependencies" = "text" }
    { "dependencies.label" = "Dependencies" }
    { "dependencies.value" }
    { "due_assign" = "text" }
    { "due_assign.label" = "Due to assign" }
    { "due_assign.value" = "YYYY/MM/DD" }
    { "due_close" = "text" }
    { "due_close.label" = "Due to close" }
    { "due_close.value" = "YYYY/MM/DD" }
    { "include_gantt" = "checkbox" }
    { "include_gantt.label" = "Include in GanttChart" }
    { "include_gantt.value" }
    {  }
  }
  { "ticket-workflow"
    { "accept" = "new -> assigned" }
    { "accept.operations" = "set_owner_to_self" }
    { "accept.permissions" = "TICKET_MODIFY" }
    { "leave" = "* -> *" }
    { "leave.default" = "1" }
    { "leave.operations" = "leave_status" }
    { "reassign" = "new,assigned,reopened -> new" }
    { "reassign.operations" = "set_owner" }
    { "reassign.permissions" = "TICKET_MODIFY" }
    { "reopen" = "closed -> reopened" }
    { "reopen.operations" = "del_resolution" }
    { "reopen.permissions" = "TICKET_CREATE" }
    { "resolve" = "new,assigned,reopened -> closed" }
    { "resolve.operations" = "set_resolution" }
    { "resolve.permissions" = "TICKET_MODIFY" }
    {  }
  }
  { "timeline"
    { "changeset_show_files" = "0" }
    { "default_daysback" = "30" }
    { "ticket_show_details" = "false" }
    {  }
  }
  { "trac"
    { "check_auth_ip" = "true" }
    { "database" = "sqlite:db/trac.db" }
    { "default_charset" = "iso-8859-15" }
    { "default_handler" = "WikiModule" }
    { "ignore_auth_case" = "false" }
    { "mainnav" = "wiki,timeline,roadmap,browser,tickets,newticket,search" }
    { "metanav" = "login,logout,settings,help,about" }
    { "permission_store" = "DefaultPermissionStore" }
    { "repository_dir" = "/var/www/svn/ftdb" }
    { "templates_dir" = "/usr/share/trac/templates" }
    {  }
  }
  { "wiki"
    { "ignore_missing_pages" = "false" }
  }
)
