# Voice commands for Claude Code integration
# Part of Dectation V2

# Session management
start claude [session]: user.claude_start_session()
(stop | close) claude [session]: user.claude_stop_session()

# Basic sending
send to claude: user.claude_send_clipboard()
claude <user.text>$: user.claude_send_prompt(text)

# Quick action templates
claude review [this]: user.claude_review()
claude refactor [this]: user.claude_refactor()
claude document [this]: user.claude_document()
claude write tests: user.claude_write_tests()
claude debug [this]: user.claude_debug()
claude explain [this]: user.claude_explain()
claude optimize [this]: user.claude_optimize()
claude security [review]: user.claude_security_review()
