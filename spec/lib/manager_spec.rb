require 'spec_helper'

describe TypografRu::Manager do

  subject{ described_class.instance }

  before(:each){ subject.clear }

  describe "#register" do
    it "should add new record to mapping" do
      subject.mapping.should be_empty
      subject.register(String, :to_s, :some_option => 10)
      subject.mapping.should == { String => { :to_s => { :some_option => 10 } } }
    end
  end

  describe "#clear" do
    it "should clear mapping for given class" do
      subject.register(String, :to_s, :some => :conf)
      subject.register(Fixnum, :to_s)
      subject.mapping.should == {
          String => { :to_s => { :some => :conf } },
          Fixnum => { :to_s => {} }
      }

      subject.clear(Fixnum)
      subject.mapping.should == { String => { :to_s => { :some => :conf } } }
    end

    it "should clear all if nil given as first arg" do
      subject.register(String, :to_s, :some => :conf)
      subject.register(Fixnum, :to_s)
      subject.mapping.should == {
          String => { :to_s => { :some => :conf } },
          Fixnum => { :to_s => {} }
      }

      subject.clear
      subject.mapping.should == { }
    end
  end

  describe "#exec_for" do
    it "should do nothing if object's class not registered" do
      RestClient.should_not_receive(:post)
      subject.exec_for(35)
    end

    it "should do nothing if attr's value nil or empty" do
      object = mock('SomeClass')
      object.stub(:attr_1)
      object.stub(:attr_2){ '' }
      object.stub(:attr_1_changed?){ true }
      object.stub(:attr_2_changed?){ true }
      subject.register(object.class, :attr_1)
      subject.register(object.class, :attr_2)
      RestClient.should_not_receive(:post)
      subject.exec_for(object)
    end

    context "no options were given for attr" do
      it "should raise error when object doesn't respond to :attr_changed?" do
        object = mock('SomeClass')
        object.stub(:title){ 'some text' }
        object.should_not respond_to(:title_changed?)
        subject.register(object.class, :title)
        expect{ subject.exec_for(object) }.should raise_error
      end

      it "should change attribute value from http://typograf.ru" do
        object = mock('SomeClass')
        object.stub(:title){ 'some text' }
        object.stub(:title_changed?){ true }
        object.stub(:title=)

        subject.register(object.class, :title)
        RestClient.should_receive(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }

        subject.exec_for(object)
      end
    end

    it "should not call attr_changed? when :no_check => true option is given" do
      object = mock('SomeClass')
      object.stub(:title){ 'some text' }
      object.stub(:title=)

      object.should_not_receive(:title_changed?)
      subject.register(object.class, :title, :no_check => true)
      RestClient.should_receive(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }

      subject.exec_for(object)
    end

    it "should do nothing if option :if is proc and it returns false" do
      object = mock('SomeClass')
      subject.register(object.class, :title, :if => proc{ |r| false } )
      RestClient.should_not_receive(:post)
      subject.exec_for(object)
    end

    it "should call service if option :if is proc and it returns true" do
      object = mock('SomeClass')
      object.stub(:title){ 'some text' }
      object.stub(:title_changed?){ true }
      object.stub(:title=)

      subject.register(object.class, :title, :if => proc{ |r| true } )
      RestClient.should_receive(:post).with('http://typograf.ru/webservice/', :text => object.title, :chr => 'UTF-8'){ '' }

      subject.exec_for(object)
    end
  end

end
