"""check-permission.py — Check if a tool call is in the permissions allow list.

Usage: python3 check-permission.py <settings_file> <hook_input_file>
Exit codes: 0 = allowed, 1 = not allowed
"""
import sys
import json
import fnmatch


def main():
    if len(sys.argv) < 3:
        sys.exit(0)

    settings_path = sys.argv[1]
    input_path = sys.argv[2]

    # Read hook input
    try:
        with open(input_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    if not tool_name:
        sys.exit(0)

    # Read settings
    try:
        with open(settings_path, "r", encoding="utf-8") as f:
            settings = json.load(f)
    except Exception:
        sys.exit(0)

    allow = settings.get("permissions", {}).get("allow", [])
    command = tool_input.get("command", "") if isinstance(tool_input, dict) else ""

    for rule in allow:
        # Exact match (e.g., 'Read', 'Glob')
        if rule == tool_name:
            sys.exit(0)

        # Pattern with parens (e.g., 'Bash(git *)', 'Skill(*)')
        if "(" in rule and ")" in rule:
            rule_tool = rule[: rule.index("(")]
            rule_param = rule[rule.index("(") + 1 : rule.rindex(")")]

            if rule_tool != tool_name:
                continue

            if rule_param == "*":
                sys.exit(0)

            # For Bash, match command parameter
            if tool_name == "Bash" and command:
                if fnmatch.fnmatch(command, rule_param):
                    sys.exit(0)
            # For Read with path patterns
            elif tool_name == "Read":
                read_path = (
                    tool_input.get("file_path", "")
                    if isinstance(tool_input, dict)
                    else ""
                )
                if fnmatch.fnmatch(read_path, rule_param):
                    sys.exit(0)

    # No match found — not allowed
    sys.exit(1)


if __name__ == "__main__":
    main()
