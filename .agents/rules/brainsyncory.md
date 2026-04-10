

# Project Memory — colombia_go_nuevo
> 669 notes | Score threshold: >40

## Safety — Never Run Destructive Commands

> Dangerous commands are actively monitored.
> Critical/high risk commands trigger error notifications in real-time.

- **NEVER** run `rm -rf`, `del /s`, `rmdir`, `format`, or any command that deletes files/directories without EXPLICIT user approval.
- **NEVER** run `DROP TABLE`, `DELETE FROM`, `TRUNCATE`, or any destructive database operation.
- **NEVER** run `git push --force`, `git reset --hard`, or any command that rewrites history.
- **NEVER** run `npm publish`, `docker rm`, `terraform destroy`, or any irreversible deployment/infrastructure command.
- **NEVER** pipe remote scripts to shell (`curl | bash`, `wget | sh`).
- **ALWAYS** ask the user before running commands that modify system state, install packages, or make network requests.
- When in doubt, **show the command first** and wait for approval.

**Stack:** Dart · Flutter + Provider · DB: Firebase

## 📝 NOTE: 1 uncommitted file(s) in working tree.\n\n## Important Warnings

- **⚠️ GOTCHA: Fixed null crash in Inicio — prevents null/undefined runtime crashes** — -         }catch (e,s){
+         } catch (e,s){
-         }
+     
- **⚠️ GOTCHA: Fixed null crash in String — prevents null/undefined runtime crashes** — -         }
+         }catch (e,s){
- 
+           print(e);
-    
- **⚠️ GOTCHA: Added OAuth2 authentication** — - - ⚠️ GOTCHA: Optimized CORE — evolves the database schema to support
- **⚠️ GOTCHA: Added OAuth2 authentication** — - - ⚠️ GOTCHA: Added OAuth2 authentication — evolves the database sche
- **⚠️ GOTCHA: Optimized CORE — evolves the database schema to support new requirements** — - ## Known issues
+ ## 🏛️ CORE ARCHITECTURE
- 
+ > **CRITICAL:** The 
- **⚠️ GOTCHA: Added OAuth2 authentication — evolves the database schema to support new requ...** — - > 654 notes | Score threshold: >40
+ > 655 notes | Score threshold: 

## Active: `lib`

- **⚠️ GOTCHA: Fixed null crash in Inicio — prevents null/undefined runtime crashes**
- **⚠️ GOTCHA: Fixed null crash in String — prevents null/undefined runtime crashes**
- **Fixed null crash in GoogleSignInException — prevents null/undefined runtime c... — confirmed 4x**
- **Fixed null crash in UserCredential — prevents null/undefined runtime crashes — confirmed 4x**
- **what-changed in gastronomia.dart — confirmed 3x**

## Project Standards

- Fixed null crash in GoogleSignInException — prevents null/undefined runtime c... — confirmed 4x
- Fixed null crash in UserCredential — prevents null/undefined runtime crashes — confirmed 4x
- what-changed in gastronomia.dart — confirmed 3x
- what-changed in shared-context.json — confirmed 6x
- Added OAuth2 authentication — evolves the database schema to support new requ... — confirmed 5x
- convention in .gitignore
- Added OAuth2 authentication — evolves the database schema to support new requ... — confirmed 3x
- problem-fix in agent-rules.md — confirmed 9x

## Known Fixes

- ❌ Build flags: -g;-DANDROID;-fdata-sections;-ffunction-sections;-funwind-tables;-fstack-protector-stro → ✅ problem-fix in CMakeOutput.log
- ❌ - - Fixed null crash in CategoriaRestaurante — wraps unsafe operation in error bo... → ✅ problem-fix in agent-rules.md
- ❌ - - Fixed null crash in GoogleSignInException — prevents null/undefined runtime c... → ✅ problem-fix in agent-rules.md
- ❌ - - ⚠️ GOTCHA: Fixed null crash in Inicio — prevents null/undefined runtime crashes → ✅ problem-fix in agent-rules.md
- ❌ - - Fixed null crash in MOBILE — prevents null/undefined runtime crashes → ✅ problem-fix in agent-rules.md

## Recent Decisions

- Optimized Score — evolves the database schema to support new requirements
- Optimized Score — evolves the database schema to support new requirements
- Optimized Score — evolves the database schema to support new requirements
- decision in analysis_options.yaml

## Learned Patterns

- Avoid: gotcha in IDEWorkspaceChecks.plist (seen 2x)
- Always: what-changed in checksums.lock — confirmed 6x (seen 2x)
- Decision: decision in workspace.xml (seen 2x)
- Agent generates new migration for every change (squash related changes)
- Agent installs packages without checking if already installed

### 📚 Core Framework Rules: [better-auth/providers]
# Authentication Providers Reference

Provide a quick reference for Better Auth authentication providers:

1. If a provider name is provided (e.g., "google", "github", "email"), show detailed configuration for that provider
2. Otherwise, show an overview of all available providers organized by category:
   - OAuth providers (Google, GitHub, Discord, etc.)
   - Email/Password authentication
   - Magic link authentication
   - Passwordless authentication
   - Social providers
3. For each provider, display:
   - Configuration requirements (client ID, secret, etc.)
   - Setup instructions
   - Code example for integration
4. Use clear visual indicators for different provider types
5. Mention any special requirements or considerations
6. Provide link to full documentation: https://better-auth.com/docs

If the user is currently working on authentication code, offer to generate integration code for the selected provider.

- [Flutter/Dart] Use const constructors wherever possible (improves rebuild performance)
- [Flutter/Dart] Dispose controllers in StatefulWidget.dispose()
- [Firebase] Set Firestore security rules (never leave default open rules)

## Available Tools (ON-DEMAND only)
- `sys_core_01(q)` — Deep search when stuck
- `sys_core_05(query)` — Full-text lookup
> Context above IS your context. Do NOT call sys_core_14() at startup.
