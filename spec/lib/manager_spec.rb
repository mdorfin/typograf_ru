require 'spec_helper'

describe TypografRu::Manager do

  subject{ described_class.instance }

  before(:each){ subject.clear }

  describe "#register" do
    it "should add new record to mapping" do
      expect(subject.mapping).to be_empty
      subject.register(String, :to_s, some_option: 10)
      expect(subject.mapping).to eq(String => { to_s: { some_option: 10 }})
    end
  end

  describe "#clear" do
    let(:expected) do 
      {
        String => {to_s: {some: :conf }},
        Fixnum => {to_s: {}}
      }
    end

    before do
      subject.register(String, :to_s, some: :conf)
      subject.register(Fixnum, :to_s)      
      expect(subject.mapping).to eq expected     
    end

    it "should clear mapping for given class" do  
      subject.clear(Fixnum)      
      expect(subject.mapping).to eq(String => { to_s: { some: :conf }})
    end

    it "should clear all if nil given as first arg" do
      subject.clear
      expect(subject.mapping).to eq({})
    end
  end

  describe "#exec_for" do
    before do 
      allow(RestClient).to receive(:post).and_return(double('Response', force_encoding: true))
    end

    it "should do nothing if object's class not registered" do
      subject.exec_for(35)
      expect(RestClient).not_to have_received(:post)
    end

    it "should do nothing if attr's value nil or empty" do
      object = instance_double('SomeClass', :attr_1 => nil, :attr_2 => '', 
                                :attr_1_changed? => true, :attr_2_changed? => true)

      subject.register(object.class, :attr_1)
      subject.register(object.class, :attr_2)      
      
      subject.exec_for(object)            
      expect(RestClient).not_to have_received(:post)
    end

    context "no options were given for attr" do
      it "should raise error when object doesn't respond to :attr_changed?" do
        object = instance_double('SomeClass', title: 'some text')
        expect(object).to_not respond_to(:title_changed?)
        subject.register(object.class, :title)
        expect{ subject.exec_for(object) }.to raise_error
      end

      it "should change attribute value from http://typograf.ru" do
        object = instance_double('SomeClass', :title => 'some text', :title_changed? => true, :title= => nil )
        subject.register(object.class, :title)

        subject.exec_for(object)
        expect(RestClient).to have_received(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }
      end
    end

    it "should not call attr_changed? when :no_check => true option is given" do
      object = instance_double('SomeClass', :title => 'some text',  :title= => nil)
      
      allow(object).to receive(:title_changed?)
      subject.register(object.class, :title, :no_check => true)

      subject.exec_for(object)
      expect(object).not_to have_received(:title_changed?)
      expect(RestClient).to have_received(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }
    end

    it "should do nothing if option :if is proc and it returns false" do
      object = instance_double('SomeClass')
      subject.register(object.class, :title, :if => proc{ |r| false } )

      subject.exec_for(object)
      expect(RestClient).not_to have_received(:post)
    end

    it "should call service if option :if is proc and it returns true" do
      object = instance_double('SomeClass', :title => 'some text', :title_changed? => true, :title= => nil)
      subject.register(object.class, :title, :if => proc{ |r| true } )
    
      subject.exec_for(object)
      expect(RestClient).to have_received(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }
    end
  end
end
