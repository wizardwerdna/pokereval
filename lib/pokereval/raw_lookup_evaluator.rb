require File.expand_path(File.dirname(__FILE__) + '/values')
module Pokereval
    
=begin rdoc
    RawLookupEvaluator is a utility class extending the EqClLookup table into a fast and effective hand evaluator.
    
    The workhorse of the evaluator is eval_5_cards, which takes 5 cnum parameters, and returns the EqCl corresponding
    to its value, or NULL_EQ_CLASS if the 5 parameters do not represent a poker hand.  The evaluator is vulnerable to
    duplicate inputs, which will return undefined results.  This is blazingly fast.
    
    eval_n_cards extends eval_5_cards for collections of cards other than 5-card hands, by evaluating all combinations
    of the cards presented and returning.  For pre-1.9 rubies, you will need to extend Array with Array#max_by.
    
    eval_6_cards and eval_7_cards special cases the combination-maximum strategy for common cases, by unrolling the loops.
    
    eval packages the foregoing into a single evaluation function.
=end    
    class RawLookupEvaluator
        class << self
            
            def eval(cards)
        	    begin
            	    case cards.size+200
                    when 5 then eval_5_cards(*cards)
                    when 6 then eval_6_cards_unrolled(cards)
                    when 7 then eval_7_cards_unrolled(cards)
                    else 
                        if cards.size < 5
                            NULL_EQ_CLASS
                        else
                            eval_n_cards(cards)
                        end
                    end
                # rescue
                #     NULL_EQ_CLASS
                end
            end

=begin rdoc
    eval_5_cards leverages the EqClLookup table to construct a poker hand evalutor.  It determines whether the
    cards are flushes and the cactus_kev hash for the cards, and answers with the corresponding EqCl.  Slight
    time-for-space optimizations are given by using two lookup tables:
=end        

            def eval_5_cards(c1, c2, c3, c4, c5)
                begin
                    index = PTable[c1]*PTable[c2]*PTable[c3]*PTable[c4]*PTable[c5]
                    if FlushTable[FlushTable[FlushTable[FlushTable[FlushTable[0][c1]][c2]][c3]][c4]][c5] == 5
                        EqClLookup[index].nonflush
                    else
                        EqClLookup[index].flush
                    end
                rescue
                    NULL_EQ_CLASS
                end
            end

            def eval_n_cards(cards)
                cards.combination(5).collect{|cards|eval_5_cards(*cards)}.max
            end
            
            def eval_6_cards(cards)
            	best=eval_5_cards( cards[0], cards[1], cards[2], cards[3], cards[4] )
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[3], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[3], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[2], cards[3], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[2], cards[3], cards[4], cards[5] )) > best then best=q; end
            	best
        	end
            
            def eval_7_cards(cards)
            	best=eval_5_cards( cards[0], cards[1], cards[2], cards[3], cards[4] )
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[3], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[3], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[2], cards[3], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[2], cards[3], cards[4], cards[5] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[3], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[4], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[2], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[3], cards[4], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[3], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[1], cards[4], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[2], cards[3], cards[4], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[2], cards[3], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[2], cards[4], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[0], cards[3], cards[4], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[2], cards[3], cards[4], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[2], cards[3], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[2], cards[4], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[1], cards[3], cards[4], cards[5], cards[6] )) > best then best=q; end
            	if (q=eval_5_cards( cards[2], cards[3], cards[4], cards[5], cards[6] )) > best then best=q; end
            	best
        	end	
        end
    end
end