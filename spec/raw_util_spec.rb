require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include Pokereval

context RawUtil do
    before(:each) do
        @util = RawUtil
    end
    context :cstr2cnum do
        it "should convert strings properly" do
            @util.cstr2cnum("2c").should == 0
            @util.cstr2cnum("3c").should == 1
            @util.cstr2cnum("Ac").should == 12
            @util.cstr2cnum("2d").should == 13
            @util.cstr2cnum("Ad").should == 25
            @util.cstr2cnum("Ah").should == 38
            @util.cstr2cnum("As").should == 51
        end
    
        it "should handle errors reasonably" do
            @util.cstr2cnum(nil).should be_nil
            @util.cstr2cnum("2cd").should == 0
            @util.cstr2cnum("fred").should be_nil
        end
    end

    context :cnum2cstr do
        it "should convert integers properly" do
            @util.cnum2cstr(0).should == "2c"
            @util.cnum2cstr(1).should == "3c"
            @util.cnum2cstr(12).should == "Ac"
            @util.cnum2cstr(13).should == "2d"
            @util.cnum2cstr(25).should == "Ad"
            @util.cnum2cstr(38).should == "Ah"
            @util.cnum2cstr(51).should == "As"
        end
        it "should handle errors reasonably" do
            @util.cnum2cstr(nil)[0..0].should == "*"
            @util.cnum2cstr("2cd")[0..0].should == "*"
            @util.cnum2cstr(-1)[0..0].should == "*"
            @util.cnum2cstr(52)[0..0].should == "*"
        end
        it "should be the inverse of cstr2cnum for values in range" do
            52.times do |cnum|
                @util.cstr2cnum(@util.cnum2cstr(cnum)).should == cnum
            end
        end
    end
    
    context :hstr2harr do
        it "should convert strings properly" do
            @util.hstr2harr("6c 5c 4c 3c 2c").should == [4,3,2,1,0]
        end
    end
    context :harr2hstr do
        it "should convert arrays properly" do
            @util.harr2hstr([4,3,2,1,0]).should == "6c 5c 4c 3c 2c"
        end
        
        it "should be the inverse of hstr2harr for values in range" do
            (0..51).to_a.combination(2).each do |harr|
                @util.hstr2harr(@util.harr2hstr(harr)).should == harr
            end
        end
    end
    context :eqcl2hstr do
        it "should convert ranks and suits properly" do
            (EqClTable[1..25]+EqClTable[1000..1025]+EqClTable[-25..-1]).each do |eq_cl|
                @util.eqcl2hstr(eq_cl).split(' ').collect{|each|each[0..0]}.join.should == eq_cl.cards
                (@util.eqcl2hstr(eq_cl).split(' ').collect{|each|each[1..1]}.uniq.join.length==1).should ==
                    (eq_cl.kind == STRAIGHT_FLUSH_KIND || eq_cl.kind == FLUSH_KIND)
            end
        end
    end
    
    context :eqcl2arr do
        it "should convert ranks and suits properly" do
            (EqClTable[1..25]+EqClTable[1000..1025]+EqClTable[-25..-1]).each do |eq_cl|
                @util.eqcl2harr(eq_cl).collect{|each|each%13}.should == 
                    @util.hstr2harr(@util.eqcl2hstr(eq_cl)).collect{|each|each%13}
            end
        end
    end

    context :eqcl2harr6 do
        it "should create hands properly" do
            @util.eqcl2harr6(EqClTable[   9]).should == [4, 3, 2, 1, 0, 6]      # 6-high straight flush
            @util.eqcl2harr6(EqClTable[  22]).should == [12, 25, 38, 51, 0, 13] # quad aces over deuce
            @util.eqcl2harr6(EqClTable[ 178]).should == [12, 25, 38, 39, 0, 1]  # aces full of deuces
            @util.eqcl2harr6(EqClTable[1599]).should == [5, 3, 2, 1, 0, 13]     # seven high flush
            @util.eqcl2harr6(EqClTable[1605]).should == [7, 19, 31, 43, 3, 0]   # nine high straight
            @util.eqcl2harr6(EqClTable[2465]).should == [0, 13, 26, 42, 2, 1]   # trip deuces 54
            @util.eqcl2harr6(EqClTable[3324]).should == [1, 14, 26, 39, 3, 2]   # Treys and Deuces 5
            @util.eqcl2harr6(EqClTable[6179]).should == [0, 13, 31, 42, 2, 1]   # Pair of deuces, 754
            @util.eqcl2harr6(EqClTable[7450]).should == [6, 18, 29, 41, 1, 0]   # 87543
        end
    end
end