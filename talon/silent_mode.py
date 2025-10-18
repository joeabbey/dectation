"""
Silent listening mode - Talon listens but doesn't type anything
except for specific wake word commands like "hey claude"
"""

from talon import Module

mod = Module()

# Define a custom "silent" mode
mod.mode("silent", "Silent listening mode - only responds to wake words like 'hey claude'")
