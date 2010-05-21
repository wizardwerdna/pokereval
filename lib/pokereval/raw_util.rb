require File.expand_path(File.dirname(__FILE__) + '/values')
module Pokereval
=begin rdoc
RawUtil is a utility class for converting between string and integer representations of poker cards; and 
between string and array representations of collections of poker cards.  These representations shall be
referred to in this code as rawforms.

The mapping is between a simple 0-based ranking of integers (cnums) representing cards, all clubs first,
then diamonds hearts and spades, in ascending ranks, and two-character strings (cstrs), the first character 
representing the rank, and the second representing the suit.  Thus:

    "2c" => 0       # deuce of clubs
    "3c" => 1       # trey of clubs
    ...
    "Ac" => 12      # ace of clubs
    "2d" => 13      # deuce of diamonds
    ...
    "Ad" => 25      # ace of diamonds
    ...
    "Ah" => 38      # ace of hearts
    ...
    "As" => 51      # ace of spades
    
collections of card representations are given by arrays of cnums (harrs) and space-delimited strings (cstrs).

RawUtil also provides some functions converting EqCl instances to harr that are probably useless except for testing.
=end
    class RawUtil
        class << self

            def cnum2cstr cnum
                begin
                    ranknum = cnum % 13
                    suitnum = cnum / 13
                    return "*#{cnum}*" unless suitnum.between?(0,3)
                    RANKS[ranknum..ranknum]+SUITS[suitnum..suitnum]
                rescue
                    return "*#{cnum.inspect}*"
                end
            end

            def cstr2cnum cstr
                begin
                    ranknum = RANK_LOOKUP[cstr[0..0]]
                    suitnum = SUIT_LOOKUP[cstr[1..1]]
                    ranknum && suitnum && suitnum * 13 + ranknum
                rescue
                    nil
                end
            end
            
            def hstr2harr hstr
                begin
                    hstr.strip.split(' ').collect{|each|cstr2cnum each}
                rescue
                    "*#{hstr.inspect}*"
                end
            end
            
            def harr2hstr harr
                harr.collect{|each|cnum2cstr each}.join(' ')
            end
            
            # generate an hstr corresponding to a hand in the eq_cl
            def eqcl2hstr eq_cl
                suits = ['c', 'd','h','s']
                suit_cycle = if eq_cl.kind==STRAIGHT_FLUSH_KIND || eq_cl.kind==FLUSH_KIND
                    suits[0..0].cycle
                else
                    suits.cycle
                end
                eq_cl.cards.split('').collect{|each| each + suit_cycle.next}.join(' ')
            end
            
            # generate a harr corresponding to a hand in the eq_cl
            def eqcl2harr eq_cl
                hstr2harr(eqcl2hstr(eq_cl))
            end
            
            # generate a harr corresponding to the eq_cl with 1 irrelevant card added, if possible
            def eqcl2harr6 eq_cl
                harr = eqcl2harr eq_cl
                harr + [irrelevant_cards(harr, eq_cl).min]
            end
            
            def flush? harr
                harr.inject(0){|state, cnum| FlushTable[state][cnum]}.between?(1,4)
            end
            
            def longest_run_in_ascending_array harr
                # R: longest_run_in 0..len-1 is length
                # I: longest_run_in 0..i-1 is length AND
                #         longest_run_ending in i-1 is anchored_length, ending with last
                length, anchored_length, i, last = 1,1,1,harr[0]
                while i != harr.count
                    if last+1==harr[i]
                        anchored_length+=1
                    else
                        anchored_length=1
                    end
                    i, last, length = i+1, harr[i], [length, anchored_length].max
                end
                length
            end
            
            def wrap_aces_in_ascending_array harr
                harr.unshift(-1) if harr.last==12
                harr
            end
            
            def slow_straight? harr
                5 <= longest_run_in_ascending_array(
                        wrap_aces_in_ascending_array(
                            harr.collect{|each| each%13}.uniq.sort))
            end

            def irrelevant_cards harr, eq_cl
                eq_cl_harr = eqcl2harr(eq_cl)
                available_cards = (0..51).to_a - harr
                case eq_cl.kind
                when STRAIGHT_FLUSH_KIND
                    available_cards -= [eq_cl_harr.first+1] unless (eq_cl_harr.first%13) == 12
                when FOUR_OF_A_KIND_KIND
                    available_cards.reject!{|cnum| (cnum%13) > (eq_cl_harr.last%13)}
                when FULL_HOUSE_KIND
                    available_cards.reject!{|cnum| (cnum%13) == (eq_cl_harr.first%13)}
                when FLUSH_KIND
                    flush_suit = harr.first/13
                    flush_cards = harr.select{|cnum| cnum/13 == flush_suit}
                    lowest_flush_card_rank = flush_cards.min%13
                    available_cards.reject! do |cnum| 
                        cnum/13==flush_suit && 
                            (cnum%13 > lowest_flush_card_rank || slow_straight?(flush_cards+[cnum]))
                    end
                when STRAIGHT_KIND
                    available_cards.reject!{|cnum| (1+cnum%13) == (eq_cl_harr.first%13)}
                when THREE_OF_A_KIND_KIND
                    ranks_in_hand = harr.collect{|cnum|cnum%13}.uniq
                    available_cards.reject!{|cnum| ranks_in_hand.member?(cnum%13)}
                    rankminkicker = harr[3..harr.count].collect{|each| each%12}.min
                    available_cards.reject!{|cnum| (cnum%13) > rankminkicker}
                    available_cards.reject!{|cnum| slow_straight?(harr+[cnum])}
                when TWO_PAIR_KIND
                    harr_ranks = harr.collect{|each| each%13}
                    # note that a rank can be BOTH a kicker and a pair for these purposes, such as in AAKK22
                    kicker_ranks = harr_ranks - [harr[0]%13, harr[2]%13]
                    harr_counts = harr_ranks.inject({}) do |hash, cnum|
                        hash[cnum] ||= 0
                        hash[cnum] += 1
                        hash
                    end
                    pair_ranks = harr_counts.keys.select{|key| harr_counts[key]==2}
                    second_pair_rank = harr[2]%13
                    rankminkicker = kicker_ranks.min
                    available_cards.reject! do |cnum|
                        cnum_rank = cnum%13;
                        pair_ranks.member?(cnum_rank) ||
                        kicker_ranks.any?{|kicker_rank|
                            (cnum_rank == kicker_rank && kicker_rank > second_pair_rank)} ||
                        cnum_rank > rankminkicker
                    end
                    available_cards.reject!{|cnum| slow_straight?(harr+[cnum])}                    
                when PAIR_KIND, HIGHEST_CARD_KIND
                    harr_ranks = harr.collect{|cnum|cnum%13}.uniq
                    harr_ranks.each do |harr_rank|
                        available_cards.reject!{|cnum| (cnum%13) == harr_rank}
                    end
                    available_cards.reject!{|cnum| (cnum%13) > (eq_cl_harr.last%13)}
                    available_cards.reject!{|cnum| slow_straight?(harr+[cnum])}
                else
                    raise "invalid eq_cl"
                end
                available_cards
            end
        end
    end
end