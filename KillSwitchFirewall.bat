@echo off
:: -----------------------------
:: Kill Switch Batch Script
:: Function: Blocks all network traffic except for specified IP communication,
:: adds firewall rules to enhance security, block specific system updates,
:: and prevent specified programs from accessing the network.
:: -----------------------------

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Please run this script as an administrator.
    pause
    exit /b 1
)

:: Prompt user for IP address to allow
set /p ip_address=Please enter the IP address to allow:

:: Reset firewall rules to default
netsh advfirewall reset

:: Set default inbound and outbound policies to "block"
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

:: Delete all existing firewall rules
netsh advfirewall firewall delete rule name=all

:: Allow all inbound and outbound traffic for the specified IP address (TCP and UDP)
netsh advfirewall firewall add rule name="Allow Outbound to %ip_address%" dir=out action=allow protocol=any remoteip=%ip_address%
netsh advfirewall firewall add rule name="Allow Inbound from %ip_address%" dir=in action=allow protocol=any remoteip=%ip_address%

:: Block specific ports (inbound and outbound)
for %%p in (134,135,137,138,139,445,593,1025,2745,3127,3389,6129) do (
    netsh advfirewall firewall add rule name="Block Port %%p Inbound" dir=in action=block protocol=TCP localport=%%p
    netsh advfirewall firewall add rule name="Block Port %%p Outbound" dir=out action=block protocol=TCP remoteport=%%p
)

:: Block ICMP Echo Requests (prevent ping)
netsh advfirewall firewall add rule name="Block ICMPv4 In Echo Request" protocol=icmpv4:8,any dir=in action=block
netsh advfirewall firewall add rule name="Block ICMPv6 In Echo Request" protocol=icmpv6:128,any dir=in action=block

:: Block inbound traffic from private networks (LAN)
netsh advfirewall firewall add rule name="Block LAN Inbound 1" dir=in action=block remoteip=10.0.0.0-10.255.255.255
netsh advfirewall firewall add rule name="Block LAN Inbound 2" dir=in action=block remoteip=172.16.0.0-172.31.255.255
netsh advfirewall firewall add rule name="Block LAN Inbound 3" dir=in action=block remoteip=192.168.0.0-192.168.255.255

:: Add additional block rules

:: 1. Block all inbound SMB traffic
netsh advfirewall firewall add rule name="Block SMB Inbound" dir=in action=block protocol=TCP localport=445

:: 2. Block all inbound RDP traffic
netsh advfirewall firewall add rule name="Block RDP Inbound" dir=in action=block protocol=TCP localport=3389

:: 3. Block Windows Remote Management ports (WinRM)
netsh advfirewall firewall add rule name="Block WinRM Inbound" dir=in action=block protocol=TCP localport=5985-5986

:: 4. Block TFTP traffic
netsh advfirewall firewall add rule name="Block TFTP Inbound" dir=in action=block protocol=UDP localport=69

:: 5. Block Telnet traffic
netsh advfirewall firewall add rule name="Block Telnet Inbound" dir=in action=block protocol=TCP localport=23

:: Block Windows Update related services

:: Block Windows Update auto-update client (wuauclt.exe)
netsh advfirewall firewall add rule name="Block Windows Update (wuauclt.exe) Inbound" dir=in action=block program="%windir%\system32\wuauclt.exe"
netsh advfirewall firewall add rule name="Block Windows Update (wuauclt.exe) Outbound" dir=out action=block program="%windir%\system32\wuauclt.exe"

:: Block Windows Update automatic agent (usoclient.exe)
netsh advfirewall firewall add rule name="Block Windows Update (usoclient.exe) Inbound" dir=in action=block program="%windir%\system32\usoclient.exe"
netsh advfirewall firewall add rule name="Block Windows Update (usoclient.exe) Outbound" dir=out action=block program="%windir%\system32\usoclient.exe"

:: Block Windows Update service (svchost.exe for Windows Update)
netsh advfirewall firewall add rule name="Block Windows Update Service (svchost.exe) Inbound" dir=in action=block program="%windir%\system32\svchost.exe" service="wuauserv"
netsh advfirewall firewall add rule name="Block Windows Update Service (svchost.exe) Outbound" dir=out action=block program="%windir%\system32\svchost.exe" service="wuauserv"

:: Block specific programs (add the paths of programs you wish to block below)

:: Example: Block a specific program (replace the path with the actual program path)
:: netsh advfirewall firewall add rule name="Block Program ABC Inbound" dir=in action=block program="C:\Program Files\XYZ\abc.exe"
:: netsh advfirewall firewall add rule name="Block Program ABC Outbound" dir=out action=block program="C:\Program Files\XYZ\abc.exe"

:: Prompt user to manually add custom block rules if needed
echo To block other programs, please add the appropriate rules in the script.

echo Operation completed. Communication is allowed only with %ip_address% and additional security measures have been implemented.

pause
exit /b 0
