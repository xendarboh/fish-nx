function __nx_get_packages
  if test -e package.json && type -q jq
    cat package.json | jq -r '.devDependencies | keys | .[]' | grep '^@nrwl/' | sort
  end
end

function __nx_generate
  set -l packages (__nx_get_packages)
  for pkg in $packages
    set -l f "node_modules/$pkg/generators.json"
    if test -f $f && type -q jq
      set -l generators (cat $f | jq -r -M '.generators | keys | .[]')
      for generator in $generators
        set -l g (string trim $generator)
        set -l description (cat $f | jq -r --arg G "$g" -M '.generators | .[$G] | .description')
        echo -e "$pkg:$generator\t$description"
      end
    end
  end
end

function __nx_get_projects
  npx nx show projects
end

function __nx_run
  set -l projects (__nx_get_projects)
  for project in $projects
    if test -d apps/$project
      set dir "apps"
    else if test -d libs/$project
      set dir "libs"
    else
      continue
    end

    # get package.json scripts
    if test -e $dir/$project/package.json && type -q jq
      set -l scripts (cat $dir/$project/package.json | jq -r -M '.scripts | keys | .[]' 2>/dev/null)
      for script in $scripts
        echo -e "$project:$script"
      end
    end

    # get project.json target(:configuration)
    if test -e $dir/$project/project.json && type -q jq
      set -l targets ( \
        cat $dir/$project/project.json \
          | jq -r -M '.targets | to_entries | map("\(.key as $target | try (.value.configurations | keys | map("\($target):\(.)") | .[]) catch $target)") | .[]' \
          2>/dev/null \
      )
      for target in $targets
        echo -e "$project:$target"
      end
    end
  end
end


set -l nx_commands g generate run run-many affected affected:graph affected-dep-graph print-affected daemon graph dep-graph format:check format:write format workspace-lint workspace-generator workspace-schematic migrate report init list reset clear-cache connect connect-to-nx-cloud repair view-logs exec watch show

# ❯ nx --help                                                                                                                                                                                    2023-04-07 14:49:15
# Smart, Fast and Extensible Build System
#
# Commands:
#   nx generate <generator> [_..]                    Generate or update source code (e.g., nx generate @nrwl/js:lib mylib).                                                                                [aliases: g]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a g -d '[alias: generate]'
complete -f -c nx -n "__fish_seen_subcommand_from g; and not __fish_seen_subcommand_from (__nx_generate)" -a "(__nx_generate)"
complete -f -c nx -n "__fish_seen_subcommand_from (__nx_generate); and not __fish_seen_subcommand_from --" -a "--"

complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a generate -d 'Generate or update source code (e.g., nx generate @nrwl/js:lib mylib).'
complete -f -c nx -n "__fish_seen_subcommand_from generate; and not __fish_seen_subcommand_from (__nx_generate)" -a "(__nx_generate)"
complete -f -c nx -n "__fish_seen_subcommand_from (__nx_generate); and not __fish_seen_subcommand_from --" -a "--"

#   nx run [project][:target][:configuration] [_..]  Run a target for a project
#                                                    (e.g., nx run myapp:serve:production).
#
#                                                    You can also use the infix notation to run a target:
#                                                    (e.g., nx serve myapp --configuration=production)
#
#                                                    You can skip the use of Nx cache by using the --skip-nx-cache option.
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a run -d 'Run a target for a project (e.g., nx run myapp:serve:production).'
complete -f -c nx -n "__fish_seen_subcommand_from run; and not __fish_seen_subcommand_from (__nx_run)" -a "(__nx_run)"
complete -f -c nx -n "__fish_seen_subcommand_from (__nx_run); and not __fish_seen_subcommand_from --" -a "--"

#   nx run-many                                      Run target for multiple listed projects
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a run-many -d 'Run target for multiple listed projects'

#   nx affected                                      Run target for affected projects
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a affected -d 'Run target for affected projects'

#   nx affected:apps                                 Print applications affected by changes            [deprecated: Use `nx print-affected --type=app --select=projects` instead. This command will be removed in v15.]
#   nx affected:libs                                 Print libraries affected by changes               [deprecated: Use `nx print-affected --type=lib --select=projects` instead. This command will be removed in v15.]

#   nx affected:graph                                Graph dependencies affected by changes                                                                                               [aliases: affected:dep-graph]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a affected:graph -d 'Graph dependencies affected by changes'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a affected:dep-graph -d '[alias: affected:graph]'

#   nx print-affected                                Prints information about the projects and targets affected by changes
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a print-affected -d 'Prints information about the projects and targets affected by changes'

#   nx daemon                                        Prints information about the Nx Daemon process or starts a daemon process
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a daemon -d 'Prints information about the Nx Daemon process or starts a daemon process'

#   nx graph                                         Graph dependencies within workspace                                                                                                           [aliases: dep-graph]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a graph -d 'Graph dependencies within workspace'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a dep-graph -d '[alias: graph]'

#   nx format:check                                  Check for un-formatted files
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a format:check -d 'Check for un-formatted files'

#   nx format:write                                  Overwrite un-formatted files                                                                                                                     [aliases: format]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a format:write -d 'Overwrite un-formatted files'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a format       -d '[alias: format:write]'

#   nx workspace-lint [files..]                      Lint nx specific workspace files (nx.json, workspace.json)
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a workspace-lint -d 'Lint nx specific workspace files (nx.json, workspace.json)'

#   nx workspace-generator [name]                    Runs a workspace generator from the tools/generators directory                                                                      [aliases: workspace-schematic]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a workspace-generator -d 'Runs a workspace generator from the tools/generators directory'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a workspace-schematic -d '[alias: workspace-generator]'

# OLD: complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a workspace-schematic -d 'Runs a workspace schematic from the tools/schematics directory'
# OLD: complete -f -c nx -n "__fish_seen_subcommand_from workspace-schematic; and not __fish_seen_subcommand_from (__nx_workspace_schematic)" -a "(__nx_workspace_schematic)"
# OLD: complete -f -c nx -n "__fish_seen_subcommand_from (__nx_workspace_schematic); and not __fish_seen_subcommand_from --" -a "--"

#   nx migrate [packageAndVersion]                   Creates a migrations file or runs migrations from the migrations file.
#                                                    - Migrate packages and create migrations.json (e.g., nx migrate @nrwl/workspace@latest)
#                                                    - Run migrations (e.g., nx migrate --run-migrations=migrations.json). Use flag --if-exists to run migrations only if the migrations file exists.
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a migrate -d 'Creates a migrations file or runs migrations from the migrations file.'

#   nx report                                        Reports useful version numbers to copy into the Nx issue template
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a report -d 'Reports useful version numbers to copy into the Nx issue template'

#   nx init                                          Adds nx.json file and installs nx if not installed already
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a init -d 'Adds nx.json file and installs nx if not installed already'

#   nx list [plugin]                                 Lists installed plugins, capabilities of installed plugins and other available plugins.
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a list -d 'Lists installed plugins, capabilities of installed plugins and other available plugins.'

#   nx reset                                         Clears all the cached Nx artifacts and metadata about the workspace and shuts down the Nx Daemon.                                           [aliases: clear-cache]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a reset -d 'Clears all the cached Nx artifacts and metadata about the workspace and shuts down the Nx Daemon.'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a clear-cache -d '[alias: reset]'

#   nx connect                                       Connect workspace to Nx Cloud                                                                                                       [aliases: connect-to-nx-cloud]
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a connect -d 'Connect workspace to Nx Cloud'
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a connect-to-nx-cloud -d '[alias: connect]'

#   nx repair                                        Repair any configuration that is no longer supported by Nx.
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a repair -d 'Repair any configuration that is no longer supported by Nx.'

#   nx view-logs                                     Enables you to view and interact with the logs via the advanced analytic UI from Nx Cloud to help you debug your issue. To do this, Nx needs to connect your
#                                                    workspace to Nx Cloud and upload the most recent run details. Only the metrics are uploaded, not the artefacts.
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a view-logs -d 'Enables you to view and interact with the logs via the advanced analytic UI from Nx Cloud'

#   nx exec                                          Executes any command as if it was a target on the project
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a exec -d 'Executes any command as if it was a target on the project'

#   nx watch                                         Watch for changes within projects, and execute commands
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a watch -d 'Watch for changes within projects, and execute commands'

#   nx show <object>                                 Show information about the workspace (e.g., list of projects)
complete -f -c nx -n "not __fish_seen_subcommand_from $nx_commands" -a show -d 'Show information about the workspace (e.g., list of projects)'

# Options:
#   --help     Show help                                                                                                                                                                                      [boolean]
#   --version  Show version number                                                                                                                                                                            [boolean]
