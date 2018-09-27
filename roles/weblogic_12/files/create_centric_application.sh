#!/usr/bin/expect

# 2016-06-02 - Geert van der Ploeg
# expect script voor het automatisch aanmaken van een Centric forms applicatie
# package expect benodigd

set timeout -1

spawn "./wldt.sh"

expect {
  "Continue? (Y/N)" {
    send "Y\n"
    exp_continue
  }
   "Press Enter to continue . . ." {
    send "\r"
    exp_continue
  }
  "Alive" {
    #exp_continue
  }
  "A --> Manage Application" {
    send "A\n"
    exp_continue
  }
   "A --> Application Menu" {
    send "A\n"
    exp_continue
  }
  "C --> Create Application" {
    send "C\n"
    #exp_continue
  }
  "C --> Create FormsApp" {
    send "C\n"
    #exp_continue
  }
}


set timeout 3

expect "Do You want to continue? (Y/N):"
send "Y\n"

set timeout -1



expect {
  "Press Enter to continue . . ." {
    send "\r"
    exp_continue
  }
  "Return to Main Menu" {
    send "X\n"
    exp_continue
  }
  "X --> Exit WebLogic Deployment Tool" {
    send "X\n"
  }
  "X --> Exit WLDT" {
    send "X\n"
  }
}
