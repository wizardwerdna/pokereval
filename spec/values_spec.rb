require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context "EqClTable" do
    it "should be an Array" do
        Pokereval::EqClTable.should be_an Array
    end
    
    it "should have indices that correspond to equivalence class codes" do
        Pokereval::EqClTable.each_with_index do |each, index|
            Pokereval::EqClTable[index].code.should == index
        end
    end
    
    it "should compare correctly" do
        Pokereval::EqClTable.each_with_index do |each, index|
            Pokereval::EqClTable[index].should == Pokereval::EqClTable[index]
            (Pokereval::EqClTable[index] < Pokereval::EqClTable.first).should  == (index != 0)
            (Pokereval::EqClTable[index] > Pokereval::EqClTable.last).should  == (index != Pokereval::EqClTable.size-1)
        end
    end
    
    it "should begin with the null poker hand equivalence class" do
        Pokereval::EqClTable.first.kind.should == Pokereval::NULL_HAND
    end
    
    it "should have the first non-null hand a royal flush" do
        @royal_flush_eq = Pokereval::EqClTable[1]
        @royal_flush_eq.cards.should == "AKQJT"
        @royal_flush_eq.kind.should == Pokereval::ROYAL_FLUSH_KIND        
        @royal_flush_eq.hash.should == 41 * 37 * 31 * 29 * 23
    end
    
    it "should end with an unsuited 7 high" do
        @seven_high_eq = Pokereval::EqClTable.last
        @seven_high_eq.cards.should == "75432"
        @seven_high_eq.kind.should == Pokereval::HIGHEST_CARD_KIND
        @seven_high_eq.hash.should == 13 * 7 * 5 * 3 * 2
    end
    
    it "should have proper values for quad aces and a king" do
        @quad_eq = Pokereval::EqClTable[11]
        @quad_eq.cards.should == "AAAAK"
        @quad_eq.kind.should == Pokereval::FOUR_OF_A_KIND_KIND
        @quad_eq.hash.should == (41**4) * 37
    end
end

context "EqClLookup" do
    before(:each) do
        @number_of_flushes = Pokereval::EqClLookup.values.select{|each| each.flush != Pokereval::NULL_EQ_CLASS}.size
        @number_of_nonflushes = Pokereval::EqClLookup.values.select{|each| each.nonflush != Pokereval::NULL_EQ_CLASS}.size
    end
    it "should have an entry for every non-null equivalence class" do
        (@number_of_flushes+@number_of_nonflushes).should == Pokereval::EqClTable.size - 1
    end
    it "should properly evaluate a royal flush" do
        Pokereval::EqClLookup[41 * 37 * 31 * 29 * 23].flush.code.should == 1
    end
    it "should properly evaluate quad aces and a king" do
        Pokereval::EqClLookup[(41**4) * 37].nonflush.code.should == 11
    end
    it "should properly evaluate a 7-high" do
        Pokereval::EqClLookup[13 * 7 * 5 * 3 * 2].nonflush.should == Pokereval::EqClTable.last
    end 
    it "should properly evaluate a non-hand" do
        Pokereval::EqClLookup[0].flush.should == Pokereval::NULL_EQ_CLASS
        Pokereval::EqClLookup[0].nonflush.should == Pokereval::NULL_EQ_CLASS
    end
end