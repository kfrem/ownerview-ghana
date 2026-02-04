-- OwnerView Ghana - Seed Ghana Towns Data
-- Major towns and cities across all regions of Ghana

INSERT INTO ownerview_gh_towns (name, region, country) VALUES
-- Greater Accra Region
('Accra', 'Greater Accra', 'Ghana'),
('Tema', 'Greater Accra', 'Ghana'),
('Madina', 'Greater Accra', 'Ghana'),
('Ashaiman', 'Greater Accra', 'Ghana'),
('Teshie', 'Greater Accra', 'Ghana'),
('Nungua', 'Greater Accra', 'Ghana'),
('Kasoa', 'Greater Accra', 'Ghana'),
('Dansoman', 'Greater Accra', 'Ghana'),
('Spintex', 'Greater Accra', 'Ghana'),
('East Legon', 'Greater Accra', 'Ghana'),

-- Ashanti Region
('Kumasi', 'Ashanti', 'Ghana'),
('Obuasi', 'Ashanti', 'Ghana'),
('Ejisu', 'Ashanti', 'Ghana'),
('Mampong', 'Ashanti', 'Ghana'),
('Konongo', 'Ashanti', 'Ghana'),
('Bekwai', 'Ashanti', 'Ghana'),
('Tepa', 'Ashanti', 'Ghana'),

-- Western Region
('Sekondi-Takoradi', 'Western', 'Ghana'),
('Tarkwa', 'Western', 'Ghana'),
('Axim', 'Western', 'Ghana'),
('Prestea', 'Western', 'Ghana'),
('Bogoso', 'Western', 'Ghana'),

-- Central Region
('Cape Coast', 'Central', 'Ghana'),
('Winneba', 'Central', 'Ghana'),
('Swedru', 'Central', 'Ghana'),
('Kasoa', 'Central', 'Ghana'),
('Saltpond', 'Central', 'Ghana'),
('Apam', 'Central', 'Ghana'),

-- Eastern Region
('Koforidua', 'Eastern', 'Ghana'),
('Akosombo', 'Eastern', 'Ghana'),
('Nkawkaw', 'Eastern', 'Ghana'),
('Nsawam', 'Eastern', 'Ghana'),
('Mpraeso', 'Eastern', 'Ghana'),
('Kibi', 'Eastern', 'Ghana'),
('Akropong', 'Eastern', 'Ghana'),

-- Volta Region
('Ho', 'Volta', 'Ghana'),
('Hohoe', 'Volta', 'Ghana'),
('Keta', 'Volta', 'Ghana'),
('Kpando', 'Volta', 'Ghana'),
('Aflao', 'Volta', 'Ghana'),

-- Northern Region
('Tamale', 'Northern', 'Ghana'),
('Yendi', 'Northern', 'Ghana'),
('Savelugu', 'Northern', 'Ghana'),
('Salaga', 'Northern', 'Ghana'),
('Bimbilla', 'Northern', 'Ghana'),

-- Upper East Region
('Bolgatanga', 'Upper East', 'Ghana'),
('Bawku', 'Upper East', 'Ghana'),
('Navrongo', 'Upper East', 'Ghana'),

-- Upper West Region
('Wa', 'Upper West', 'Ghana'),
('Lawra', 'Upper West', 'Ghana'),
('Jirapa', 'Upper West', 'Ghana'),

-- Brong-Ahafo Region
('Sunyani', 'Brong-Ahafo', 'Ghana'),
('Techiman', 'Brong-Ahafo', 'Ghana'),
('Berekum', 'Brong-Ahafo', 'Ghana'),
('Wenchi', 'Brong-Ahafo', 'Ghana'),
('Kintampo', 'Brong-Ahafo', 'Ghana')
ON CONFLICT (name) DO NOTHING;
