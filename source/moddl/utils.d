module moddl.utils;

import std.traits, std.meta;
import std.regex;
import std.range;

import moddl.main;

alias BasicElementOf(Range) = Unqual!(ElementEncodingType!Range);

auto isMatch(R, RegEx)(R input, RegEx re)
  if(isSomeString!R && is(RegEx : Regex!(BasicElementOf!R))){

  import std.range;
  return input.matchAll(re).walkLength != 0;
}

import moddl.file;
import std.file, std.stdio, std.json;

FileList currentFileList(){
	if(exists(fileListName)){
		auto node = fileListName.readText.parseJSON();
		return node["files"].array.toFileList;
	}else{
		FileList a;
		return a;
	}
}


string unzip(string fileName){
	import std.zip;
	import std.path;
	import std.file;

	auto zip = new ZipArchive(fileName.read);
	auto target = dirName(fileName);
	foreach(de; zip.directory.byValue){
		import std.string;
		auto path = buildPath(target, de.name.split("/").buildPath);
		//path.writeln;

		if(!exists(path.dirName)) mkdirRecurse(path.dirName);

		zip.expand(de);

		if(!exists(path)){
			/*ファイルのパスであるか*/
			if(isMatch(path, regex(`\.[\w]+`))){
				std.file.write(path, cast(void[])(de.expandedData));
			}else{
				mkdirRecurse(path);
			}
		}
	}

  import std.path : pathSplitter;
  return zip.directory.byValue.front.name.pathSplitter.front;
}
