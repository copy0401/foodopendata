require 'fileutils'

$img_extentions = "jpg,png,jpeg,bmp" # any space is not allowd
$root = Dir.getwd()
$posts_dir = "source/_posts"
$img_dir = "source/images/blog"
$img_src_prefix = ""

def search_for_imgs()
    Dir.glob("*.{#{$img_extentions}}")
end

def mvfile(src, dst)
    FileUtils.mv(src, dst)
end

Dir.chdir($posts_dir)
search_for_imgs().each do |img|
    puts "Now processing #{img}..."
    Dir.glob("*.{md,markdown}").each do |mdfilename|
        mdcontent = IO.read(mdfilename)
        if mdcontent.index(img)
            puts "\tFind #{img} refered in #{mdfilename}"
            subdirname = mdfilename.chomp(File.extname(mdfilename))

            # build correspond directory
            dir = "#{$root}/#{$img_dir}/#{subdirname}"
            puts "\t#{dir} exists" if Dir.exists?(dir)
            puts "\tI am going to mkdir: #{dir}" if not Dir.exists?(dir)

            puts "\t#{$root}: #{Dir.exists?($root)}"
            puts "\t#{$root}/source: #{Dir.exists?($root+"/source")}"
            puts "\t#{$root}/source/images: #{Dir.exists?($root+"/source/images")}"
            puts "\t#{$root}/#{$img_dir}: #{Dir.exists?($root+"/"+$img_dir)}"

            if not Dir.exist?(dir)
                FileUtils.mkdir("#{$root}/#{$img_dir}/#{subdirname}")
            end
            puts "\tmv #{img} #{$root}/#{$img_dir}/#{subdirname}/#{img}"
            FileUtils.mv(img, "#{$root}/#{$img_dir}/#{subdirname}/#{img}")

            # modify the links in the post
            mdcontent.gsub!("/#{$posts_dir}/#{img}", "/images/blog/#{subdirname}/#{img}")
            puts "\t/#{$posts_dir}/#{img} is replaced with /images/blog/#{subdirname}/#{img}"
            File.open(mdfilename, 'w') do |f|
               f.write  mdcontent
            end

            # git add
            puts "git add #{$root}/#{$img_dir}/#{subdirname}/#{img}"
            system "git add #{$root}/#{$img_dir}/#{subdirname}/#{img}"
        end
    end
end