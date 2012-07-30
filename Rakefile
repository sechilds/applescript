#Rake.application.options.trace = true

rule '.scpt' => '.applescript' do |t|
	sh %{osacompile -o '#{t.name}' '#{t.source}'}
end

rule '.dir' do |t|
        dest = "~/Library/Scripts/" + t.name.sub(/\.dir/,'')
        sh %{mkdir -p #{dest}}
end

task :default => [:random, :application]
task :application => [:mail]

desc "Build random scripts"
task :random_compile => ['Random.dir'] + FileList['Random/*.applescript'].ext("scpt")

desc "Build scripts for iCal"
task :ical_compile => ['Applications/iCal.dir'] + FileList['iCal/*.applescript'].ext("scpt")

desc "Build scripts for Mail.app"
task :mail_compile => ['Applications/Mail.dir'] + FileList['Mail/*.applescript'].ext("scpt")

desc "Copy Scripts to Library Folder"
task :random => :random_compile do
	puts "Copying Random Scripts to Library Folder"
	output = "~/Library/Scripts/Random"
	sh %{cp Random/*.scpt #{output}}
	puts "Done"
end

desc "Copy Scripts to iCal Folder"
task :ical => :ical_compile do
	puts "Copying iCal Scripts to Library Folder"
	output = "~/Library/Scripts/Applications/iCal"
	sh %{cp iCal/*.scpt #{output}}
	puts "Done"
end

desc "Copy Scripts to Mail Folder"
task :mail => :mail_compile do
	puts "Copying Mail Scripts to Library Folder"
	output = "~/Library/Scripts/Applications/Mail"
	sh %{cp Mail/*.scpt #{output}}
	puts "Done"
end

task :ical_clean => FileList['Applications/iCal/*.applescript'].sub(/\.applescript/,'.scpt')

task :mail_clean => FileList['Applications/Mail/*.applescript'].sub(/\.applescript/,'.scpt')

task :clean => FileList['*.scpt'].each do |t|
        puts t
end

def find_source(scptfile)
	base = File.basename(scptfile, '.scpt')
	SRC.find { |s| File.basename(s, '.applescript') == base }
end

