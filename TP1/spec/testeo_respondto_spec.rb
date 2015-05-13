require 'rspec'
require_relative '../src/multi_method.rb'

class A
  partial_def :concat, [String, Integer] do |s1,n|
    s1 * n
  end

  partial_def :concat, [Object, Object] do |o1, o2|
    "Objetos concatenados"
  end
end

describe 'Los Match' do

  it 'no deben fallar cuando hablamos de clases' do
   expect(A.new.respond_to?(:concat, false, [Class,Integer])).to be true
  end
end