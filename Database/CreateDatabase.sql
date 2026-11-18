
SET NOCOUNT ON;

CREATE TABLE Users (
    UserID        INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(150) NOT NULL UNIQUE,
    Phone         NVARCHAR(20)  NULL,
    Address       NVARCHAR(250) NULL,
    PasswordSalt  NVARCHAR(50)  NOT NULL,
    PasswordHash  NVARCHAR(100) NOT NULL,
    Role          NVARCHAR(20)  NOT NULL DEFAULT 'Customer',
    LoyaltyPoints INT NOT NULL DEFAULT 0,
    IsActive      BIT NOT NULL DEFAULT 1,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(60) NOT NULL UNIQUE,
    Description  NVARCHAR(250) NULL,
    ImageUrl     NVARCHAR(200) NULL
);

CREATE TABLE Products (
    ProductID    INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID   INT NOT NULL REFERENCES Categories(CategoryID),
    ProductName  NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(500) NULL,
    Price        DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    ImageUrl     NVARCHAR(200) NULL,
    Stock        INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    IsReadyToday BIT NOT NULL DEFAULT 0,
    IsEggless    BIT NOT NULL DEFAULT 0,
    IsActive     BIT NOT NULL DEFAULT 1,
    CreatedAt    DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE CartItems (
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,
    UserID     INT NOT NULL REFERENCES Users(UserID),
    ProductID  INT NOT NULL REFERENCES Products(ProductID),
    Quantity   INT NOT NULL CHECK (Quantity > 0),
    AddedAt    DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE PickupSlots (
    SlotID    INT IDENTITY(1,1) PRIMARY KEY,
    SlotLabel NVARCHAR(50) NOT NULL,
    Capacity  INT NOT NULL DEFAULT 5,
    IsActive  BIT NOT NULL DEFAULT 1
);

CREATE TABLE Orders (
    OrderID         INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT NOT NULL REFERENCES Users(UserID),
    OrderDate       DATETIME NOT NULL DEFAULT GETDATE(),
    SubTotal        DECIMAL(10,2) NOT NULL,
    DeliveryFee     DECIMAL(10,2) NOT NULL DEFAULT 0,
    PointsDiscount  DECIMAL(10,2) NOT NULL DEFAULT 0,
    TotalAmount     DECIMAL(10,2) NOT NULL,
    Status          NVARCHAR(30) NOT NULL DEFAULT 'Pending',
    DeliveryType    NVARCHAR(20) NOT NULL DEFAULT 'Delivery',
    DeliveryAddress NVARCHAR(250) NULL,
    ContactPhone    NVARCHAR(20) NULL,
    PreferredDate   DATE NULL,
    SlotID          INT NULL REFERENCES PickupSlots(SlotID),
    IsGift          BIT NOT NULL DEFAULT 0,
    Notes           NVARCHAR(500) NULL
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL REFERENCES Orders(OrderID),
    ProductID   INT NOT NULL REFERENCES Products(ProductID),
    ProductName NVARCHAR(100) NOT NULL,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL
);

CREATE TABLE OrderStatusHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT NOT NULL REFERENCES Orders(OrderID),
    Status    NVARCHAR(30) NOT NULL,
    ChangedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Payments (
    PaymentID      INT IDENTITY(1,1) PRIMARY KEY,
    OrderID        INT NOT NULL REFERENCES Orders(OrderID),
    PaymentMethod  NVARCHAR(30) NOT NULL,
    Amount         DECIMAL(10,2) NOT NULL,
    PaymentStatus  NVARCHAR(20) NOT NULL,
    TransactionRef NVARCHAR(50) NULL,
    PaidAt         DATETIME NULL
);

CREATE TABLE GiftDetails (
    GiftID           INT IDENTITY(1,1) PRIMARY KEY,
    OrderID          INT NOT NULL REFERENCES Orders(OrderID),
    RecipientName    NVARCHAR(100) NOT NULL,
    RecipientPhone   NVARCHAR(20) NOT NULL,
    RecipientAddress NVARCHAR(250) NOT NULL,
    GiftMessage      NVARCHAR(300) NULL
);

CREATE TABLE CustomOrders (
    CustomOrderID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID         INT NOT NULL REFERENCES Users(UserID),
    CakeSize       NVARCHAR(30) NOT NULL,
    Flavor         NVARCHAR(50) NOT NULL,
    Filling        NVARCHAR(50) NOT NULL,
    EggOption      NVARCHAR(20) NOT NULL,
    Occasion       NVARCHAR(50) NULL,
    DesignNotes    NVARCHAR(500) NULL,
    CakeMessage    NVARCHAR(100) NULL,
    AllergyNotes   NVARCHAR(300) NULL,
    ReferenceImage NVARCHAR(200) NULL,
    RequiredDate   DATE NOT NULL,
    DeliveryType   NVARCHAR(20) NOT NULL DEFAULT 'Pickup',
    QuotedPrice    DECIMAL(10,2) NULL,
    AdminNote      NVARCHAR(300) NULL,
    Status         NVARCHAR(30) NOT NULL DEFAULT 'Pending Review',
    CreatedAt      DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Reviews (
    ReviewID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID    INT NOT NULL REFERENCES Users(UserID),
    ProductID INT NOT NULL REFERENCES Products(ProductID),
    OrderID   INT NULL REFERENCES Orders(OrderID),
    Rating    INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment   NVARCHAR(500) NULL,
    IsVisible BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    Name       NVARCHAR(100) NOT NULL,
    Email      NVARCHAR(150) NOT NULL,
    Subject    NVARCHAR(100) NOT NULL,
    Message    NVARCHAR(1000) NOT NULL,
    IsRead     BIT NOT NULL DEFAULT 0,
    CreatedAt  DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE LoyaltyTransactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID        INT NOT NULL REFERENCES Users(UserID),
    OrderID       INT NULL REFERENCES Orders(OrderID),
    Points        INT NOT NULL,
    Description   NVARCHAR(200) NOT NULL,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID         INT NOT NULL REFERENCES Users(UserID),
    OrderID        INT NULL,
    Title          NVARCHAR(100) NOT NULL,
    Message        NVARCHAR(500) NOT NULL,
    Channel        NVARCHAR(20) NOT NULL DEFAULT 'In-App',
    IsRead         BIT NOT NULL DEFAULT 0,
    CreatedAt      DATETIME NOT NULL DEFAULT GETDATE()
);

/* ---------------- Seed data ---------------- */
-- Passwords: Admin@123 (admin), Customer@123 (customers). Stored as PBKDF2-SHA256 hashes.
INSERT INTO Users (FullName, Email, Phone, Address, PasswordSalt, PasswordHash, Role, LoyaltyPoints) VALUES
(N'Bakery Admin',   N'admin@bakedwithlove.com', N'9800000001', N'Baked With Love, Lakeside, Pokhara',
 N'8bXQ9jT7jEo0cKSFXNAgiQ==', N'sjyf8vgjY4NYEOB7O6UOmQY8EmB6MrfRCux/OTl2O2E=', N'Admin', 0),
(N'Anisha Sharma',  N'customer@bakedwithlove.com', N'9811111111', N'Baneshwor, Kathmandu',
 N'hNw/OHFlZ+VG6lEBn6+H+A==', N'2eHQkpVzHo3Fc5/WmW5nhJa+AweZxaXCFFXNib1VUAo=', N'Customer', 120),
(N'Rohan Thapa',    N'rohan@example.com', N'9822222222', N'Jhamsikhel, Lalitpur',
 N'kGY2xcUiBa7BakEdBQNCGw==', N'qHGNBh/p6I7D5QbdaXHks6Q1fbUbP6e3TK0F1K6Vr/o=', N'Customer', 45);

INSERT INTO Categories (CategoryName, Description, ImageUrl) VALUES
(N'Whole Cakes', N'Celebration cakes baked fresh to order.', N'~/Images/Products/black-forest-cake.jpg'),
(N'Cake Slices', N'A single slice of happiness.',            N'~/Images/Products/red-velvet-slice.jpg'),
(N'Cupcakes',    N'Soft cupcakes with silky frosting.',      N'~/Images/Products/rainbow-cupcake.jpg'),
(N'Cookies',     N'Crunchy, chewy, baked every morning.',     N'~/Images/Products/choco-chip-cookies.jpg'),
(N'Pastries',    N'Flaky, buttery pastries.',                 N'~/Images/Products/butter-croissant.jpg');

INSERT INTO Products (CategoryID, ProductName, Description, Price, ImageUrl, Stock, IsReadyToday, IsEggless) VALUES
(1, N'Black Forest Cake (1 lb)',     N'Chocolate sponge layered with whipped cream, cherries and dark chocolate shavings.', 1200, N'~/Images/Products/black-forest-cake.jpg', 4, 1, 0),
(1, N'Red Velvet Cake (1 lb)',       N'Velvety red sponge with smooth cream-cheese frosting.',                               1500, N'~/Images/Products/red-velvet-cake.jpg',   2, 1, 0),
(1, N'Chocolate Truffle Cake (1 lb)',N'Rich chocolate sponge covered in glossy truffle ganache.',                            1600, N'~/Images/Products/chocolate-truffle-cake.jpg', 0, 0, 0),
(1, N'Pineapple Delight Cake (1 lb)',N'Light vanilla sponge with pineapple cream. 100% eggless.',                            1100, N'~/Images/Products/pineapple-cake.jpg',   3, 1, 1),
(2, N'Black Forest Slice',           N'A generous slice of our classic Black Forest.',                                         220, N'~/Images/Products/black-forest-slice.jpg', 12, 1, 0),
(2, N'Red Velvet Slice',             N'Red velvet with cream-cheese frosting.',                                                250, N'~/Images/Products/red-velvet-slice.jpg',  8, 1, 0),
(2, N'Blueberry Cheesecake Slice',   N'Baked New York style cheesecake topped with blueberry compote.',                         320, N'~/Images/Products/blueberry-cheesecake.jpg', 3, 1, 0),
(3, N'Vanilla Rainbow Cupcake',      N'Vanilla cupcake with buttercream swirl and rainbow sprinkles.',                          150, N'~/Images/Products/rainbow-cupcake.jpg',   20, 1, 0),
(3, N'Chocolate Fudge Cupcake',      N'Moist chocolate cupcake with fudge frosting.',                                           170, N'~/Images/Products/chocolate-cupcake.jpg', 15, 1, 0),
(3, N'Strawberry Cupcake',           N'Strawberry cupcake with pink frosting. Eggless.',                                        160, N'~/Images/Products/strawberry-cupcake.jpg', 0, 0, 1),
(4, N'Choco Chip Cookies (6 pcs)',   N'Golden cookies loaded with chocolate chips.',                                            300, N'~/Images/Products/choco-chip-cookies.jpg', 10, 1, 0),
(4, N'Butter Coconut Cookies (6 pcs)',N'Melt-in-the-mouth butter cookies with toasted coconut.',                                 250, N'~/Images/Products/coconut-cookies.jpg',   6, 1, 0),
(4, N'Oatmeal Raisin Cookies (6 pcs)',N'Wholesome oats and plump raisins. Eggless.',                                            280, N'~/Images/Products/oatmeal-cookies.jpg',   0, 0, 1),
(5, N'Butter Croissant',             N'Flaky, buttery French-style croissant.',                                                 180, N'~/Images/Products/butter-croissant.jpg',  9, 1, 0),
(5, N'Chocolate Eclair',             N'Choux pastry filled with custard and dipped in chocolate.',                              200, N'~/Images/Products/chocolate-eclair.jpg',  5, 1, 0),
(5, N'Cinnamon Roll',                N'Soft swirl with cinnamon sugar and vanilla glaze.',                                      220, N'~/Images/Products/cinnamon-roll.jpg',     2, 1, 0);

INSERT INTO PickupSlots (SlotLabel, Capacity) VALUES
(N'09:00 AM - 11:00 AM', 5), (N'11:00 AM - 01:00 PM', 5), (N'01:00 PM - 03:00 PM', 5),
(N'03:00 PM - 05:00 PM', 5), (N'05:00 PM - 07:00 PM', 5);

/* Sample orders so the dashboard, history and tracking pages have data */
DECLARE @d DATETIME = GETDATE();
INSERT INTO Orders (UserID, OrderDate, SubTotal, DeliveryFee, PointsDiscount, TotalAmount, Status, DeliveryType, DeliveryAddress, ContactPhone, PreferredDate, IsGift) VALUES
(2, DATEADD(DAY,-6,@d), 1500, 100, 0, 1600, N'Delivered',        N'Delivery', N'Baneshwor, Kathmandu', N'9811111111', CAST(DATEADD(DAY,-6,@d) AS DATE), 0),
(3, DATEADD(DAY,-5,@d),  690, 100, 0,  790, N'Delivered',        N'Delivery', N'Jhamsikhel, Lalitpur', N'9822222222', CAST(DATEADD(DAY,-5,@d) AS DATE), 0),
(2, DATEADD(DAY,-3,@d), 1200,   0, 0, 1200, N'Delivered',        N'Pickup',   NULL,                   N'9811111111', CAST(DATEADD(DAY,-3,@d) AS DATE), 0),
(3, DATEADD(DAY,-2,@d), 2100,   0, 0, 2100, N'Delivered',        N'Delivery', N'Jhamsikhel, Lalitpur', N'9822222222', CAST(DATEADD(DAY,-2,@d) AS DATE), 0),
(2, DATEADD(DAY,-1,@d),  470, 100, 0,  570, N'Out for Delivery', N'Delivery', N'Baneshwor, Kathmandu', N'9811111111', CAST(@d AS DATE), 0),
(2, DATEADD(HOUR,-3,@d),1100, 100, 0, 1200, N'Pending',          N'Delivery', N'Lakeside, Pokhara',    N'9833333333', CAST(DATEADD(DAY,1,@d) AS DATE), 1);

UPDATE Orders SET SlotID = 2 WHERE OrderID = 3;

INSERT INTO OrderItems (OrderID, ProductID, ProductName, Quantity, UnitPrice) VALUES
(1, 2, N'Red Velvet Cake (1 lb)', 1, 1500),
(2, 8, N'Vanilla Rainbow Cupcake', 3, 150), (2, 5, N'Black Forest Slice', 1, 220),
(3, 1, N'Black Forest Cake (1 lb)', 1, 1200),
(4, 3, N'Chocolate Truffle Cake (1 lb)', 1, 1600), (4, 11, N'Choco Chip Cookies (6 pcs)', 1, 300), (4, 15, N'Chocolate Eclair', 1, 200),
(5, 6, N'Red Velvet Slice', 1, 250), (5, 5, N'Black Forest Slice', 1, 220),
(6, 4, N'Pineapple Delight Cake (1 lb)', 1, 1100);

INSERT INTO OrderStatusHistory (OrderID, Status, ChangedAt) VALUES
(1,N'Pending',DATEADD(DAY,-6,@d)),(1,N'Confirmed',DATEADD(DAY,-6,@d)),(1,N'Out for Delivery',DATEADD(DAY,-6,@d)),(1,N'Delivered',DATEADD(DAY,-6,@d)),
(2,N'Pending',DATEADD(DAY,-5,@d)),(2,N'Confirmed',DATEADD(DAY,-5,@d)),(2,N'Out for Delivery',DATEADD(DAY,-5,@d)),(2,N'Delivered',DATEADD(DAY,-5,@d)),
(3,N'Pending',DATEADD(DAY,-3,@d)),(3,N'Confirmed',DATEADD(DAY,-3,@d)),(3,N'Delivered',DATEADD(DAY,-3,@d)),
(4,N'Pending',DATEADD(DAY,-2,@d)),(4,N'Confirmed',DATEADD(DAY,-2,@d)),(4,N'Out for Delivery',DATEADD(DAY,-2,@d)),(4,N'Delivered',DATEADD(DAY,-2,@d)),
(5,N'Pending',DATEADD(DAY,-1,@d)),(5,N'Confirmed',DATEADD(HOUR,-20,@d)),(5,N'Out for Delivery',DATEADD(HOUR,-2,@d)),
(6,N'Pending',DATEADD(HOUR,-3,@d));

INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentStatus, TransactionRef, PaidAt) VALUES
(1,N'eSewa',1600,N'Paid',N'ESW-100001',DATEADD(DAY,-6,@d)),
(2,N'Cash on Delivery',790,N'Paid',NULL,DATEADD(DAY,-5,@d)),
(3,N'Khalti',1200,N'Paid',N'KHL-100003',DATEADD(DAY,-3,@d)),
(4,N'Card',2100,N'Paid',N'CRD-100004',DATEADD(DAY,-2,@d)),
(5,N'Cash on Delivery',570,N'Unpaid',NULL,NULL),
(6,N'eSewa',1200,N'Paid',N'ESW-100006',DATEADD(HOUR,-3,@d));

INSERT INTO GiftDetails (OrderID, RecipientName, RecipientPhone, RecipientAddress, GiftMessage) VALUES
(6, N'Sita Sharma', N'9833333333', N'Lakeside, Pokhara', N'Happy Birthday Mum! Love from Kathmandu.');

INSERT INTO Reviews (UserID, ProductID, OrderID, Rating, Comment, CreatedAt) VALUES
(2, 2, 1, 5, N'Best red velvet in town, so soft!', DATEADD(DAY,-5,@d)),
(3, 8, 2, 4, N'Kids loved the rainbow sprinkles.', DATEADD(DAY,-4,@d)),
(2, 1, 3, 5, N'Fresh cream and lots of cherries.', DATEADD(DAY,-2,@d)),
(3, 3, 4, 5, N'Super rich chocolate. Worth it.', DATEADD(DAY,-1,@d));

INSERT INTO LoyaltyTransactions (UserID, OrderID, Points, Description, CreatedAt) VALUES
(2, 1, 16, N'Earned on order #1', DATEADD(DAY,-6,@d)),
(2, 3, 12, N'Earned on order #3', DATEADD(DAY,-3,@d)),
(2, NULL, 92, N'Welcome bonus', DATEADD(DAY,-7,@d)),
(3, 2, 7, N'Earned on order #2', DATEADD(DAY,-5,@d)),
(3, 4, 21, N'Earned on order #4', DATEADD(DAY,-2,@d)),
(3, NULL, 17, N'Welcome bonus', DATEADD(DAY,-7,@d));

INSERT INTO CustomOrders (UserID, CakeSize, Flavor, Filling, EggOption, Occasion, DesignNotes, CakeMessage, AllergyNotes, RequiredDate, DeliveryType, QuotedPrice, AdminNote, Status) VALUES
(2, N'2 lb', N'Chocolate', N'Chocolate Ganache', N'Eggless', N'Birthday', N'Unicorn theme, pastel pink and purple.', N'Happy 7th Birthday Aarya', N'No nuts please', CAST(DATEADD(DAY,4,@d) AS DATE), N'Pickup', 3200, N'Unicorn topper included.', N'Quoted');

INSERT INTO Feedback (Name, Email, Subject, Message) VALUES
(N'Prakash K.', N'prakash@example.com', N'Great service', N'Ordered a gift cake for my parents from abroad and it arrived on time. Thank you!');

INSERT INTO Notifications (UserID, OrderID, Title, Message, Channel, CreatedAt) VALUES
(2, 5, N'Order #5 is out for delivery', N'Your order is on its way. Please keep your phone nearby.', N'Email', DATEADD(HOUR,-2,@d)),
(2, NULL, N'Custom cake quote ready', N'Your custom cake request #1 has been quoted at Rs. 3,200. Please confirm.', N'Email', DATEADD(HOUR,-1,@d));
