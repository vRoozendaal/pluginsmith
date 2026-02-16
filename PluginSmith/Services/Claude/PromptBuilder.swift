import Foundation

enum PromptBuilder {
    static let systemPrompt = """
        You are a Claude Code plugin and skill architect. You create precise, \
        well-structured plugin artifacts following the exact Claude Code plugin format.

        Key format rules:
        - SKILL.md files use YAML frontmatter with: name, description, version
        - Command .md files use YAML frontmatter with: description, argument-hint, allowed-tools, model
        - Agent .md files use YAML frontmatter with: name, description, tools, model, color
        - plugin.json contains: name, description, version, author, keywords
        - Skill descriptions must clearly state trigger conditions for when Claude should use the skill
        - Content should be actionable and specific, not generic
        - Use $ARGUMENTS for argument interpolation in commands
        - Reference files in references/ directory using relative paths

        Always output clean, production-ready content. No explanatory wrapper text.
        """

    static func buildAnalysisPrompt(
        sources: [SourceDocument],
        outputType: ForgeProject.OutputType
    ) -> String {
        let typeLabel = outputType == .plugin ? "plugin" : "skill"

        var prompt = """
            Analyze the following source documents and suggest a Claude Code \(typeLabel) structure.

            For each suggestion, provide:
            1. A concise name (kebab-case) and description
            2. Which content should become skill instructions vs reference materials
            3. What commands would be useful based on the content
            4. What trigger conditions/descriptions would make sense
            5. Which tools should be allowed

            Source documents:

            """

        for source in sources {
            prompt += "### \(source.fileName) (\(source.fileType.rawValue))\n"
            let truncated = String(source.rawContent.prefix(8000))
            prompt += truncated + "\n\n---\n\n"
        }

        prompt += """

            Respond ONLY with a JSON object containing a "suggestions" array. Each element:
            {
              "type": "skill" | "command" | "agent" | "reference",
              "name": "suggested-name",
              "description": "suggested description",
              "tools": ["Read", "Glob"],
              "contentMapping": "which source section maps here",
              "rationale": "why this suggestion"
            }

            Example response:
            {"suggestions": [{"type": "skill", "name": "example", "description": "...", "tools": [], "contentMapping": "...", "rationale": "..."}]}
            """

        return prompt
    }

    static func buildSkillGenerationPrompt(
        sources: [SourceDocument],
        config: SkillConfig
    ) -> String {
        var prompt = """
            Generate a complete SKILL.md file for a Claude Code skill with these specifications:

            Name: \(config.name)
            Description: \(config.description)
            Version: \(config.version)

            The skill should synthesize the following source materials into clear, \
            actionable instructions that Claude can follow when the skill is triggered. Structure with:
            - A clear overview of what this skill does
            - When to use / when not to use guidelines
            - Step-by-step workflow or methodology
            - Specific patterns, rules, and templates from the source material
            - Reference links to files in references/ directory

            Include YAML frontmatter (---name, description, version---).

            Source materials:

            """

        for source in sources {
            prompt += "### \(source.fileName)\n"
            prompt += String(source.rawContent.prefix(6000)) + "\n\n"
        }

        prompt += "\nOutput ONLY the SKILL.md content. No wrapping text."

        return prompt
    }

    static func buildCommandGenerationPrompt(
        sources: [SourceDocument],
        config: CommandConfig
    ) -> String {
        var prompt = """
            Generate a complete command markdown file for a Claude Code slash command:

            Name: /\(config.name)
            Description: \(config.description)
            """

        if !config.argumentHint.isEmpty {
            prompt += "Argument hint: \(config.argumentHint)\n"
        }
        if !config.allowedTools.isEmpty {
            prompt += "Allowed tools: \(config.allowedTools.joined(separator: ", "))\n"
        }
        if let model = config.model {
            prompt += "Model: \(model)\n"
        }

        prompt += """

            Include YAML frontmatter with: description, argument-hint, allowed-tools, model.
            Then provide clear instructions for what Claude should do when this command is invoked.

            Source materials for context:

            """

        for source in sources {
            prompt += "### \(source.fileName)\n"
            prompt += String(source.rawContent.prefix(4000)) + "\n\n"
        }

        prompt += "\nOutput ONLY the command .md file content. No wrapping text."

        return prompt
    }

    static func buildAgentGenerationPrompt(
        sources: [SourceDocument],
        config: AgentConfig
    ) -> String {
        var prompt = """
            Generate a complete agent markdown file for a Claude Code agent:

            Name: \(config.name)
            Description: \(config.description)
            Tools: \(config.tools.joined(separator: ", "))
            Model: \(config.model)
            """

        if let color = config.color {
            prompt += "Color: \(color)\n"
        }

        prompt += """

            Include YAML frontmatter with: name, description, tools, model, color.
            Then provide:
            - Core mission/purpose
            - Specialized approach/methodology
            - Step-by-step workflow
            - Output format guidance

            Source materials for context:

            """

        for source in sources {
            prompt += "### \(source.fileName)\n"
            prompt += String(source.rawContent.prefix(4000)) + "\n\n"
        }

        prompt += "\nOutput ONLY the agent .md file content. No wrapping text."

        return prompt
    }

    static func buildReadmePrompt(project: ForgeProject) -> String {
        var prompt = """
            Generate a README.md for a Claude Code plugin:

            Plugin name: \(project.name)
            Display name: \(project.displayName)
            Description: \(project.description)
            Version: \(project.version)
            Author: \(project.author.name)

            """

        if !project.pluginConfig.commands.isEmpty {
            prompt += "Commands:\n"
            for cmd in project.pluginConfig.commands {
                prompt += "- /\(cmd.name): \(cmd.description)\n"
            }
        }

        if !project.pluginConfig.skills.isEmpty {
            prompt += "\nSkills:\n"
            for skill in project.pluginConfig.skills {
                prompt += "- \(skill.name): \(skill.description)\n"
            }
        }

        if !project.pluginConfig.agents.isEmpty {
            prompt += "\nAgents:\n"
            for agent in project.pluginConfig.agents {
                prompt += "- \(agent.name): \(agent.description)\n"
            }
        }

        prompt += """

            Write a clean, concise README with:
            - Title and description
            - Installation instructions (mention Claude Code plugin system)
            - Usage section with examples
            - Available commands/skills/agents

            Output ONLY the README.md content.
            """

        return prompt
    }
}
