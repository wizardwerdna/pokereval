require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include Pokereval


context RawLookupEvaluator do
    before(:each) do
        @eval = RawLookupEvaluator
        @util = RawUtil
    end

    it "should evaluate hands correctly with card_specific evaluators" do
        EqClTable[1..EqClTable.count].each do |eq_cl|
            harr = @util.eqcl2harr eq_cl
            @eval.eval_5_cards(*harr).should == eq_cl
            harr += [@util.irrelevant_cards(harr, eq_cl).min]
            unless harr.last.nil?
                @eval.eval_6_cards(harr).should == eq_cl
                harr += [@util.irrelevant_cards(harr, eq_cl).min]
                @eval.eval_7_cards(harr).should == eq_cl unless harr.last.nil?
            end
        end
    end
    it "should evaluate 6 and 7 hands correctly with the eval_n_cards evaluator" do
        EqClTable[1..EqClTable.count].each do |eq_cl|
            harr = @util.eqcl2harr eq_cl
            @eval.eval_n_cards(harr).should == eq_cl
            harr += [@util.irrelevant_cards(harr, eq_cl).min]
            unless harr.last.nil?
                @eval.eval_n_cards(harr).should == eq_cl
                harr += [@util.irrelevant_cards(harr, eq_cl).min]
                @eval.eval_n_cards(harr).should == eq_cl unless harr.last.nil?
            end
        end
    end
    it "should evaluate 6 and 7 hands correctly with the eval evaluator" do
        EqClTable[1..EqClTable.count].each do |eq_cl|
            harr = @util.eqcl2harr eq_cl
            @eval.eval(harr).should == eq_cl
            harr += [@util.irrelevant_cards(harr, eq_cl).min]
            unless harr.last.nil?
                @eval.eval(harr).should == eq_cl
                harr += [@util.irrelevant_cards(harr, eq_cl).min]
                @eval.eval(harr).should == eq_cl unless harr.last.nil?
            end
        end
    end
end