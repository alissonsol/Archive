//----------------------------------------------------------------------
// <copyright file="DataFormat.cs" company="Microsoft">
//   Code provided "as is" as part of MSDN article
//   "Using big data and machine learning to protect your online service"
// </copyright>
//----------------------------------------------------------------------

namespace RequestsAnalysis
{
    /// <summary>
    /// Separators for input data and MapReduce process.
    /// </summary>
    internal struct DataFormat
    {
        /// <summary>
        /// Mapper input column separator.
        /// </summary>
        internal const char MapperInputColumnSeparator = ' ';

        /// <summary>
        /// Number of columns for mapper input.
        /// </summary>
        internal const int MapperInputColumns = 19;

        /// <summary>
        /// Uri referenced.
        /// </summary>
        internal const int MapperInputUriReferenceColumn = 4; // cs-uri-stem

        /// <summary>
        /// Query parameters.
        /// </summary>
        internal const int MapperInputUriQueryColumn = 5; // cs-uri-query

        /// <summary>
        /// Mapper output column separator.
        /// </summary>
        internal const char MapperOutputColumnSeparator = '\t';

        /// <summary>
        /// Key to report parsing error on input line.
        /// </summary>
        internal const string MapperOutputKeyForParsingError = "/InputParsingError";

        /// <summary>
        /// Value indicating one occurrence.
        /// </summary>
        internal const string OneOccurrence = "1";

        /// <summary>
        /// Reducer input column separator.
        /// </summary>
        internal const char ReducerInputColumnSeparator = '\t';

        /// <summary>
        /// Number of columns for reducer input.
        /// </summary>
        internal const int ReducerInputColumns = 2;

        /// <summary>
        /// Format for the reducer output.
        /// </summary>
        internal const string ReducerOutputLineFormat = "{0}\t{1}";

        /// <summary>
        /// Separates reference page from query.
        /// </summary>
        internal const char ReferenceFromQuerySeparator = '?';

        /// <summary>
        /// Separates parameter name from value.
        /// </summary>
        internal const char ParameterNameFromValueSeparator = '=';

        /// <summary>
        /// Separator for query parameters.
        /// </summary>
        internal static readonly char[] ParametersSeparator = { '&' };
    }
}