//----------------------------------------------------------------------
// <copyright file="RequestsReducer.cs" company="Microsoft">
//   Code provided "as is" as part of TechEd Europe 2014 presentation 
//   "Using big data and machine learning to protect your online service"
// </copyright>
//----------------------------------------------------------------------

namespace RequestsAnalysis
{
    using System;
    using System.IO;

    /// <summary>
    /// Program execution class.
    /// </summary>
    public class RequestsReducer
    {
        /// <summary>
        /// Application entry point.
        /// </summary>
        /// <param name="args">Application parameters.</param>
        public static void Main(string[] args)
        {
            string currentKey, previousKey = null;
            int count = 0;

            if (args.Length > 0)
            {
                Console.SetIn(new StreamReader(args[0]));
            }

            string inputLine;
            while ((inputLine = Console.ReadLine()) != null)
            {
                string[] keyValuePair = inputLine.Split(DataFormat.ReducerInputColumnSeparator);
                if (keyValuePair.Length == DataFormat.ReducerInputColumns)
                {
                    currentKey = keyValuePair[0];
                    if (currentKey != previousKey)
                    {
                        if (previousKey != null)
                        {
                            Console.WriteLine(DataFormat.ReducerOutputLineFormat, previousKey, count);
                        }

                        count = 1;
                        previousKey = currentKey;
                    }
                    else
                    {
                        count += 1;
                    }
                }
            }

            Console.WriteLine(DataFormat.ReducerOutputLineFormat, previousKey, count);
        }
    }
}
