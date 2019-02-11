module TechnicalAnalysis
  class ObvMean < Indicator

    # Returns the symbol of the technical indicator
    #
    # @return [String] A string of the symbol of the technical indicator
    def self.indicator_symbol
      "obv_mean"
    end

    # Returns the name of the technical indicator
    #
    # @return [String] A string of the name of the technical indicator
    def self.indicator_name
      "On-balance Volume Mean"
    end

    # Returns an array of valid keys for options for this technical indicator
    #
    # @return [Array] An array of keys as symbols for valid options for this technical indicator
    def self.valid_options
      %i(period)
    end

    # Validates the provided options for this technical indicator
    #
    # @param options [Hash] The options for the technical indicator to be validated
    #
    # @return [Boolean] Returns true if options are valid or raises a ValidationError if they're not
    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    # Calculates the minimum number of observations needed to calculate the technical indicator
    #
    # @param options [Hash] The options for the technical indicator
    #
    # @return [Integer] Returns the minimum number of observations needed to calculate the technical
    #    indicator based on the options provided
    def self.min_data_size(period: 10)
      period.to_i + 1
    end

    # Calculates the on-balance volume mean (OBV mean) for the data over the given period
    # https://en.wikipedia.org/wiki/On-balance_volume
    #
    # @param data [Array] Array of hashes with keys (:date_time, :close, :volume)
    # @param period [Integer] The given period to calculate the OBV mean
    #
    # @return [Array<Hash>]
    #
    #   An array of hashes with keys (:date_time, :value). Example output:
    #
    #     [
    #       {:date_time => "2019-01-09T00:00:00.000Z", :value => -642606913.0},
    #       {:date_time => "2019-01-08T00:00:00.000Z", :value => -654187384.0},
    #     ]
    def self.calculate(data, period: 10)
      period = period.to_i
      Validation.validate_numeric_data(data, :close, :volume)
      Validation.validate_length(data, period + 1)

      data = data.sort_by_hash_date_time_asc

      current_obv = 0
      obvs = []
      output = []
      prior_close = nil
      prior_volume = nil

      data.each do |v|
        volume = v[:volume]
        close = v[:close]

        unless prior_close.nil?
          current_obv += volume if close > prior_close
          current_obv -= volume if close < prior_close
          obvs << current_obv
        end

        prior_volume = volume
        prior_close = close

        if obvs.size == period
          output << { date_time: v[:date_time], value: obvs.average }
          obvs.shift
        end
      end

      output.sort_by_hash_date_time_desc
    end

  end
end
