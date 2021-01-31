//----------------------------------------------------------------------
// <copyright file="RequestsMapper.cs" company="Microsoft">
//   Code provided "as is" as part of TechEd Europe 2014 presentation
//   "Using big data and machine learning to protect your online service"
// </copyright>
//----------------------------------------------------------------------

namespace RequestsAnalysis
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;

    /// <summary>
    /// Program execution class.
    /// </summary>
    public class RequestsMapper
    {
        /// <summary>
        /// Application entry point.
        /// </summary>
        /// <param name="args">Application parameters.</param>
        public static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                Console.SetIn(new StreamReader(args[0]));
            }

            string inputLogLine;
            while ((inputLogLine = Console.ReadLine()) != null)
            {
                string outputKeyAndValues = ExtractKeyAndValuesFromLogLine(inputLogLine);

                Console.WriteLine(outputKeyAndValues);
            }
        }

        /// <summary>
        /// Extracts parameter names from query.
        /// </summary>
        /// <param name="query">Query string. Example: q=v1</param>
        /// <returns>Parameter names. Example: q=</returns>
        private static string ExtractParameterNamesFromQuery(string query)
        {
            StringBuilder sb = new StringBuilder();

            // Go through each parameter adding to output string
            string[] nameValuePairs = query.Split(DataFormat.ParametersSeparator, StringSplitOptions.RemoveEmptyEntries);
            Array.Sort(nameValuePairs, StringComparer.InvariantCultureIgnoreCase);
            List<string> uniqueParameterNames = new List<string>();
            foreach (string nameValuePair in nameValuePairs)
            {
                int indexOfSeparatorParameterNameFromValue = nameValuePair.IndexOf(DataFormat.ParameterNameFromValueSeparator);
                string paramName = nameValuePair;

                if (-1 != indexOfSeparatorParameterNameFromValue)
                {
                    paramName = nameValuePair.Substring(0, indexOfSeparatorParameterNameFromValue);
                    if (!string.IsNullOrEmpty(paramName))
                    {
                        paramName = paramName.ToLowerInvariant(); // .NET-specific: case doesn't matter
                        if (!uniqueParameterNames.Contains(paramName))
                        {
                            uniqueParameterNames.Add(paramName);
                            sb.Append(paramName);
                            sb.Append(DataFormat.ParameterNameFromValueSeparator);
                            sb.Append(DataFormat.OneOccurrence); // In the extract phase, each parameter is counted once
                            sb.Append(DataFormat.ParametersSeparator);
                        }
                    }
                }
            }

            return sb.ToString();
        }

        /// <summary>
        /// Process log line to extract key (requested URL) and data values for analytics.
        /// </summary>
        /// <param name="inputLogLine">Input string: line from log file.</param>
        /// <returns>Output line: key and values for analytics.</returns>
        private static string ExtractKeyAndValuesFromLogLine(string inputLogLine)
        {
            StringBuilder keyAndValues = new StringBuilder();

            if (!string.IsNullOrEmpty(inputLogLine))
            {
                string[] inputColumns = inputLogLine.Split(DataFormat.MapperInputColumnSeparator);
                if (inputColumns.Length != DataFormat.MapperInputColumns)
                {
                    keyAndValues.Append(DataFormat.MapperOutputKeyForParsingError);
                    keyAndValues.Append(DataFormat.MapperOutputColumnSeparator);
                    keyAndValues.Append(DataFormat.OneOccurrence);
                }
                else
                {
                    string uriReference = inputColumns[DataFormat.MapperInputUriReferenceColumn];
                    string uriQuery = inputColumns[DataFormat.MapperInputUriQueryColumn];
                    string parameterNames = ExtractParameterNamesFromQuery(uriQuery);

                    // Key = uriReference + separator + parameterNames
                    keyAndValues.Append(uriReference);
                    keyAndValues.Append(DataFormat.ReferenceFromQuerySeparator);
                    keyAndValues.Append(parameterNames);

                    keyAndValues.Append(DataFormat.MapperOutputColumnSeparator);
                    keyAndValues.Append(DataFormat.OneOccurrence);
                }
            }

            return keyAndValues.ToString();
        }
    }
}
