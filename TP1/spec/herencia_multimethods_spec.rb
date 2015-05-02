class A
  partial_def :concat, [String, String] do |str1, str2|
    str1 + str2
  end

  partial_def :metodo_extendido, [] do
    "metodo de A"
  end

  partial_def :metodo_def, [] do
    "metodo_def de A"
  end
end

class B < A
  partial_def :concat, [String, String] do |str1, str2|
    str1 + " " + str2
  end

  partial_def :metodo_extendido, [String] do |str|
    "extiende el metodo de A"
  end

  def metodo_def(param)
    param
  end
end

describe "A y B" do
  it "B concat" do
    expect(B.new.concat("con", "cat")).to eq("con cat")
  end

  it "A concat" do
    expect(A.new.concat("con", "cat")).to eq("concat")
  end

  it "B metodo" do
    expect(B.new.metodo_extendido("str")).to eq("extiende el metodo de A")
  end

  it "B metodo de A" do
    expect(B.new.metodo_extendido()).to eq("metodo de A")
  end

  it "A metodo de A" do
    expect(A.new.metodo_extendido()).to eq("metodo de A")
  end

  it "A metodo de B" do
    expect { A.new.metodo_extendido() }.to raise_error(NoMethodError)
  end

  it "A metodo_def" do
    expect(A.new.metodo_def).to eq("metodo_def de A")
  end

  it "B metodo_def" do
    expect(B.new.metodo_def("param")).to eq("param")
  end

end