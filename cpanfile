requires "Carp" => "0";
requires "Class::Accessor::Fast" => "0";
requires "Crypt::Rijndael" => "0";
requires "Crypt::URandom" => "0";
requires "Data::Entropy" => "0";
requires "Data::Entropy::Algorithms" => "0";
requires "Data::Entropy::RawSource::CryptCounter" => "0";
requires "Data::Entropy::Source" => "0";
requires "base" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Test::More" => "0";
  requires "lib" => "0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};
