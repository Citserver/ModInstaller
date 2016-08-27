module moddl.utils;

import std.traits, std.meta;
import std.regex;
import std.range;

alias BasicElementOf(Range) = Unqual!(ElementEncodingType!Range);

auto isMatch(R, RegEx)(R input, RegEx re)
  if(isSomeString!R && is(RegEx : Regex!(BasicElementOf!R))){

  import std.range;
  return input.matchAll(re).walkLength != 0;
}
