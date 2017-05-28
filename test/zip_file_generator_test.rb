require 'dmanga/zip_file_generator'
class TestZipFileGenerator < Minitest::Test
   def test_put_into_archive
       out_file = "#{File.dirname(__FILE__)}/files/test.zip"
       in_dir = "#{File.dirname(__FILE__)}/files"
       zf = DManga::ZipFileGenerator.new(in_dir, out_file)
       zf.write
       assert File.exist? out_file
       FileUtils.rm out_file
   end 
end
