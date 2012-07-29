#Rake.application.options.trace = true

rule '.applescript' => '.scpt' do |t|
        sh %{osacompile -o ~/Library/Scripts/#{t.source} #{t.name}}
end

rule '.dir' do |t|
        dest = "~/Library/Scripts/" + t.name.sub(/\.dir/,'')
        sh %{mkdir -p #{dest}}
end

task :default => [:random, :application]
task :application => [:mail]

desc "Build random scripts"
task :random => ['Random.dir'] + FileList['Random/*.applescript']

desc "Build scripts for iCal"
task :ical => ['Applications/iCal.dir'] + FileList['Applications/iCal/*.applescript']

desc "Build scripts for Mail.app"
task :mail => ['Applications/Mail.dir'] + fileList['Applications/Mail/*.applescript']

task :ical_clean => FileList['Applications/iCal/*.applescript'].sub(/\.applescript/,'.scpt')

task :mail_clean => FileList['Applications/Mail/*.applescript'].sub(/\.applescript/,'.scpt')

task :clean => FileList['*.scpt'].each do |t|
        puts t
end
