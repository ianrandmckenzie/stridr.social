class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|

      t.string :word
      # word_types are classified as documented from this
      # github project (under tag set):
      # https://github.com/yohasebe/engtagger
      # CC      Conjunction, coordinating               and, or
      # CD      Adjective, cardinal number              3, fifteen
      # DET     Determiner                              this, each, some
      # EX      Pronoun, existential there              there
      # FW      Foreign words
      # IN      Preposition / Conjunction               for, of, although, that
      # JJ      Adjective                               happy, bad
      # JJR     Adjective, comparative                  happier, worse
      # JJS     Adjective, superlative                  happiest, worst
      # LS      Symbol, list item                       A, A.
      # MD      Verb, modal                             can, could, 'll
      # NN      Noun                                    aircraft, data
      # NNP     Noun, proper                            London, Michael
      # NNPS    Noun, proper, plural                    Australians, Methodists
      # NNS     Noun, plural                            women, books
      # PDT     Determiner, prequalifier                quite, all, half
      # POS     Possessive                              's, '
      # PRP     Determiner, possessive second           mine, yours
      # PRPS    Determiner, possessive                  their, your
      # RB      Adverb                                  often, not, very, here
      # RBR     Adverb, comparative                     faster
      # RBS     Adverb, superlative                     fastest
      # RP      Adverb, particle                        up, off, out
      # SYM     Symbol                                  *
      # TO      Preposition                             to
      # UH      Interjection                            oh, yes, mmm
      # VB      Verb, infinitive                        take, live
      # VBD     Verb, past tense                        took, lived
      # VBG     Verb, gerund                            taking, living
      # VBN     Verb, past/passive participle           taken, lived
      # VBP     Verb, base present form                 take, live
      # VBZ     Verb, present 3SG -s form               takes, lives
      # WDT     Determiner, question                    which, whatever
      # WP      Pronoun, question                       who, whoever
      # WPS     Determiner, possessive & question       whose
      # WRB     Adverb, question                        when, how, however
      #
      # PP      Punctuation, sentence ender             ., !, ?
      # PPC     Punctuation, comma                      ,
      # PPD     Punctuation, dollar sign                $
      # PPL     Punctuation, quotation mark left        ``
      # PPR     Punctuation, quotation mark right       ''
      # PPS     Punctuation, colon, semicolon, elipsis  :, ..., -
      # LRB     Punctuation, left bracket               (, {, [
      # RRB     Punctuation, right bracket              ), }, ]
      # Please use these tags when recording :word_type
      t.string :word_type
      # Count how many times this word is used on Social Media
      t.integer :detected_count

      t.timestamps
    end
  end
end
