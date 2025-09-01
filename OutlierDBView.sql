        public JArray AggregateJsonList(JArray jArrayData)
        {
            HashSet<string> uniqueStores = new HashSet<string>(); // To track unique store names
            HashSet<string> uniqueStoreNos = new HashSet<string>(); // To track unique store numbers

            decimal totalNetSales = 0;
            decimal totalChargeableDiscount = 0;
            decimal totalRoyaltySubjectedAmount = 0;
            decimal totalLoyalty = 0;
            decimal totalRoyalty = 0;

            foreach (var item in jArrayData)
            {
                string storeName = item["Stores"]?.ToString() ?? "";
                string storeNo = item["StoreNo"]?.ToString() ?? "";

                // Add store only if it's unique
                if (!string.IsNullOrEmpty(storeName)) uniqueStores.Add(storeName);
                if (!string.IsNullOrEmpty(storeNo)) uniqueStoreNos.Add(storeNo);

                // Sum up the numeric fields
                totalNetSales += item["NetSales"]?.Value<decimal>() ?? 0;
                totalChargeableDiscount += item["ChargeableDiscount"]?.Value<decimal>() ?? 0;
                totalRoyaltySubjectedAmount += item["RoyaltySubjectedAmount"]?.Value<decimal>() ?? 0;
                totalLoyalty += item["Loyalty"]?.Value<decimal>() ?? 0;
                totalRoyalty += item["Royalty"]?.Value<decimal>() ?? 0;
            }

            // Construct aggregated JSON object
            JObject aggregatedObject = new JObject
            {
                ["Stores"] = string.Join(", ", uniqueStores), // Combine unique store names
                ["StoreNo"] = string.Join(", ", uniqueStoreNos), // Combine unique store numbers
                ["NetSales"] = Math.Round(totalNetSales, 2),
                ["ChargeableDiscount"] = Math.Round(totalChargeableDiscount, 2),
                ["RoyaltySubjectedAmount"] = Math.Round(totalRoyaltySubjectedAmount, 2),
                ["Loyalty"] = Math.Round(totalLoyalty, 2),
                ["Royalty"] = Math.Round(totalRoyalty, 2)
            };

            return new JArray(aggregatedObject);

        }