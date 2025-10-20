"""
Claude Code Prompt Templates for Dectation V2
Pre-built prompt patterns for common Claude interactions
Place in ~/.talon/user/ directory
"""

from talon import Module, actions

mod = Module()

# Template definitions
TEMPLATES = {
    "review": "Please review this code for best practices, potential bugs, and improvements:",
    "refactor": "Please refactor this code for better readability, maintainability, and performance:",
    "document": "Please write comprehensive documentation for this code, including docstrings and comments:",
    "test": "Please write unit tests for this code:",
    "debug": "I'm getting this error. Please explain what's wrong and suggest fixes:",
    "explain": "Please explain how this code works in detail:",
    "optimize": "Please optimize this code for better performance:",
    "security": "Please review this code for security vulnerabilities:",
}


@mod.action_class
class Actions:
    def claude_review():
        """Send code review prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["review"])

    def claude_refactor():
        """Send refactor prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["refactor"])

    def claude_document():
        """Send documentation prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["document"])

    def claude_write_tests():
        """Send test writing prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["test"])

    def claude_debug():
        """Send debug prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["debug"])

    def claude_explain():
        """Send explanation prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["explain"])

    def claude_optimize():
        """Send optimization prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["optimize"])

    def claude_security_review():
        """Send security review prompt to Claude"""
        actions.user.claude_quick_prompt(TEMPLATES["security"])
