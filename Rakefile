#Rake.application.options.trace = true

rule '.scpt' => '.applescript' do |t|
	sh %{osacompile -o '#{t.name}' '#{t.source}'}
end

rule '.dir' do |t|
        dest = "~/Library/Scripts/" + t.name.sub(/\.dir/,'')
        sh %{mkdir -p #{dest}}
end

task :default => [:random, :application]
task :application => [:mail, :omnifocus]

desc "Build random scripts"
task :random_compile => ['Random.dir'] + FileList['Random/*.applescript'].ext("scpt")

desc "Build scripts for Calendar"
task :calendar_compile => ['Applications/Calendar.dir'] + FileList['Calendar/*.applescript'].ext("scpt")

desc "Build scripts for Mail.app"
task :mail_compile => ['Applications/Mail.dir'] + FileList['Mail/*.applescript'].ext("scpt")

desc "Build scripts for OmniFocus"
task :omnifocus_compile => ['Applications/OmniFocus.dir'] + FileList['OmniFocus/*.applescript'].ext("scpt")

desc "Copy Scripts to Library Folder"
task :random => :random_compile do
	puts "Copying Random Scripts to Library Folder"
	output = "~/Library/Scripts/Random"
	sh %{cp Random/*.scpt #{output}}
	puts "Done"
end

desc "Copy Scripts to Calendar Folder"
task :calendar => :calendar_compile do
	puts "Copying Calendar Scripts to Library Folder"
	output = "~/Library/Scripts/Applications/Calendar"
	sh %{cp Calendar/*.scpt #{output}}
	puts "Done"
end

desc "Copy Scripts to Mail Folder"
task :mail => :mail_compile do
	puts "Copying Mail Scripts to Library Folder"
	output = "~/Library/Scripts/Applications/Mail"
	sh %{cp Mail/*.scpt #{output}}
	puts "Done"
end

desc "Copy Scripts to OmniFocus Folder"
task :omnifocus => :omnifocus_compile do
	puts "Copying OmniFocus Scripts to Library Folder"
	output = "~/Library/Scripts/Applications/OmniFocus"
	sh %{cp OmniFocus/*.scpt #{output}}
	puts "Done"
end


task :ical_clean => FileList['Applications/iCal/*.applescript'].sub(/\.applescript/,'.scpt')

task :mail_clean => FileList['Applications/Mail/*.applescript'].sub(/\.applescript/,'.scpt')

task :omnifocus_clean => FileList['Applications/OmniFocus/*.applescript'].sub(/\.applescript/,'.scpt')

task :clean => FileList['*.scpt'].each do |t|
        puts t
end

def find_source(scptfile)
	base = File.basename(scptfile, '.scpt')
	SRC.find { |s| File.basename(s, '.applescript') == base }
end

