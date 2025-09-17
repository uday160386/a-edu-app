import SwiftUI
import WebKit
import AVKit

// MARK: - Main App
@main
struct KidsYouTubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Models
struct Video: Identifiable, Codable {
    let id = UUID()
    let title: String
    let youtubeID: String
    let thumbnailURL: String
    let category: String
    let duration: String
    let ageRating: String
    
    enum CodingKeys: String, CodingKey {
        case title, youtubeID, thumbnailURL, category, duration, ageRating
    }
}

struct Photo: Identifiable, Codable {
    let id = UUID()
    let title: String
    let imageURL: String
    let thumbnailURL: String?
    let category: String
    let description: String?
    let ageRating: String
    
    enum CodingKeys: String, CodingKey {
        case title, imageURL, thumbnailURL, category, description, ageRating
    }
}

struct ContentResponse: Codable {
    let videos: [Video]?
    let photos: [Photo]?
    let categories: [String]?
    let lastUpdated: String?
}

enum ContentType: String, CaseIterable {
    case videos = "Videos"
    case photos = "Photos"
    
    var icon: String {
        switch self {
        case .videos: return "play.rectangle.fill"
        case .photos: return "photo.fill"
        }
    }
}

// MARK: - Content Store
class ContentStore: ObservableObject {
    @Published var videos: [Video] = []
    @Published var photos: [Photo] = []
    @Published var categories: [String] = ["All"]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    // Configuration
    private let contentURL = "https://your-domain.com/api/content.json" // Replace with your URL
    private let fallbackVideos: [Video] = [
        Video(
            title: "THE WISE CHILD : Learning Lesson for Kids",
            youtubeID: "AjZBZFuos8Q", // Actual kid-friendly video: Super Simple Songs - Colors Song
            thumbnailURL: "https://img.youtube.com/vi/AjZBZFuos8Q/maxresdefault.jpg",
            category: "Stories",
            duration: "6:38",
            ageRating: "8+"
        ),
        Video(
            title: "Bad Wolf and the Intelligent Buffalo",
            youtubeID: "2REgyGbR00w", // Actual kid-friendly video: Super Simple Songs - Count to 10
            thumbnailURL: "https://img.youtube.com/vi/2REgyGbR00w/maxresdefault.jpg",
            category: "Stories",
            duration: "4.33",
            ageRating: "8+"
        ),
        Video(
            title: "Be respectful & listen | Kids story to learn respect parents and peers",
            youtubeID: "VG3arGjg0Hk", // Actual kid-friendly video: Super Simple Songs - Old MacDonald
            thumbnailURL: "https://img.youtube.com/vi/VG3arGjg0Hk/maxresdefault.jpg",
            category: "Stories",
            duration: "9.41",
            ageRating: "1+"
        ),
        Video(
            title: "Wild Cat and The Princess Mouse",
            youtubeID: "UHUZJoqLW-I", // Actual kid-friendly video: Super Simple Songs - ABC Song
            thumbnailURL: "https://img.youtube.com/vi/UHUZJoqLW-I/maxresdefault.jpg",
            category: "Stories",
            duration: "4.19",
            ageRating: "8+"
        ),
        Video(
            title: "Story Of Needle Tree & Oak Tree",
            youtubeID: "ygOHQ7V2gBo", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/ygOHQ7V2gBo/maxresdefault.jpg",
            category: "Stories",
            duration: "15.07",
            ageRating: "8+"
        ),
        Video(
            title: "Ammadu Lets Do Kummudu Full Video Song",
            youtubeID: "tTSYcSHeGRo", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/tTSYcSHeGRo/maxresdefault.jpg",
            category: "Music",
            duration: "3.26",
            ageRating: "8+"
        ),
        Video(
            title: "Haanikaarak Bapu",
            youtubeID: "Q7F6ZlEoIUI", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/Q7F6ZlEoIUI/maxresdefault.jpg",
            category: "Music",
            duration: "5.09",
            ageRating: "8+"
        ),
        Video(
            title: "Learn Multiplication Songs for Children ",
            youtubeID: "oPINS56lDes", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/oPINS56lDes/maxresdefault.jpg",
            category: "Educational",
            duration: "6.28",
            ageRating: "8+"
        ),
        Video(
            title: "Maths Quiz for Kids ",
            youtubeID: "U_6Nr8yGfQk", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/U_6Nr8yGfQk/maxresdefault.jpg",
            category: "Educational",
            duration: "11.39",
            ageRating: "8+"
        ),
        Video(
            title: "Speak With Your Kids",
            youtubeID: "MhADBlNU59I", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/MhADBlNU59I/maxresdefault.jpg",
            category: "Educational",
            duration: "7.34",
            ageRating: "8+"
        ),
        Video(
            title: "Top 5 Skiing Destinations in Australia",
            youtubeID: "JswY0gfALt0", // Actual kid-friendly video: Shapes Song
            thumbnailURL: "https://img.youtube.com/vi/JswY0gfALt0/maxresdefault.jpg",
            category: "Travel & Tour",
            duration: "8.22",
            ageRating: "8+"
        )
    ]
    
    private let fallbackPhotos: [Photo] = [
        Photo(
            title: "Beautiful Rainbow",
            imageURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800",
            thumbnailURL: "https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=300",
            category: "Nature",
            description: "A colorful rainbow after the rain",
            ageRating: "All"
        ),
        Photo(
            title: "Cute Puppies",
            imageURL: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800",
            thumbnailURL: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=300",
            category: "Animals",
            description: "Adorable golden retriever puppies playing",
            ageRating: "All"
        )
    ]
    
    @Published var watchTime: TimeInterval = 0
    @Published var dailyWatchLimit: TimeInterval = 1800 // 30 minutes
    @Published var parentalControlsEnabled = true
    
    // Hourglass Timer
    @Published var hourglassTimer: TimeInterval = 0 // Current session timer
    @Published var hourglassLimit: TimeInterval = 900 // 15 minutes default
    @Published var isHourglassActive = false
    @Published var hourglassStartTime: Date?
    
    init() {
        loadContent()
    }
    
    // MARK: - Network Functions
    func loadContent() {
        isLoading = true
        errorMessage = nil
        
        // For now, load fallback content - replace with actual network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.loadFallbackContent()
        }
        
        // Uncomment below for actual network loading:
        /*
        guard let url = URL(string: contentURL) else {
            loadFallbackContent()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self?.errorMessage = "Unable to load content. Using cached content."
                    self?.loadFallbackContent()
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    self?.loadFallbackContent()
                    return
                }
                
                do {
                    let contentResponse = try JSONDecoder().decode(ContentResponse.self, from: data)
                    
                    self?.videos = contentResponse.videos ?? []
                    self?.photos = contentResponse.photos ?? []
                    
                    // Update categories from both videos and photos
                    var allCategories = Set<String>()
                    if let videos = contentResponse.videos {
                        allCategories.formUnion(videos.map { $0.category })
                    }
                    if let photos = contentResponse.photos {
                        allCategories.formUnion(photos.map { $0.category })
                    }
                    self?.categories = ["All"] + allCategories.sorted()
                    
                    self?.lastUpdated = Date()
                    self?.cacheContent(videos: contentResponse.videos, photos: contentResponse.photos)
                    
                } catch {
                    print("JSON decode error: \(error)")
                    self?.errorMessage = "Failed to parse content data"
                    self?.loadFallbackContent()
                }
            }
        }.resume()
        */
    }
    
    private func loadFallbackContent() {
        videos = fallbackVideos
        photos = fallbackPhotos
        var allCategories = Set<String>()
        allCategories.formUnion(fallbackVideos.map { $0.category })
        allCategories.formUnion(fallbackPhotos.map { $0.category })
        categories = ["All"] + allCategories.sorted()
    }
    
    private func cacheContent(videos: [Video]?, photos: [Photo]?) {
        if let videos = videos, let encoded = try? JSONEncoder().encode(videos) {
            UserDefaults.standard.set(encoded, forKey: "cachedVideos")
        }
        if let photos = photos, let encoded = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(encoded, forKey: "cachedPhotos")
        }
    }
    
    func refreshContent() {
        loadContent()
    }
    
    func addWatchTime(_ time: TimeInterval) {
        watchTime += time
        UserDefaults.standard.set(watchTime, forKey: "dailyWatchTime")
    }
    
    func resetDailyWatchTime() {
        watchTime = 0
        UserDefaults.standard.set(0, forKey: "dailyWatchTime")
    }
    
    // MARK: - Hourglass Timer Functions
    func startHourglassTimer() {
        isHourglassActive = true
        hourglassStartTime = Date()
        hourglassTimer = 0
    }
    
    func stopHourglassTimer() {
        isHourglassActive = false
        hourglassStartTime = nil
        hourglassTimer = 0
    }
    
    func updateHourglassTimer() {
        guard isHourglassActive, let startTime = hourglassStartTime else { return }
        hourglassTimer = Date().timeIntervalSince(startTime)
    }
    
    func resetHourglassTimer() {
        hourglassTimer = 0
        if isHourglassActive {
            hourglassStartTime = Date()
        }
    }
    
    var canWatchMore: Bool {
        if isHourglassActive && hourglassTimer >= hourglassLimit {
            return false
        }
        return !parentalControlsEnabled || watchTime < dailyWatchLimit
    }
    
    var remainingTime: TimeInterval {
        if isHourglassActive {
            return max(0, hourglassLimit - hourglassTimer)
        }
        return max(0, dailyWatchLimit - watchTime)
    }
    
    var hourglassRemainingTime: TimeInterval {
        return max(0, hourglassLimit - hourglassTimer)
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var contentStore = ContentStore()
    @State private var selectedContentType: ContentType = .videos
    @State private var selectedCategory = "All"
    @State private var showingParentalControls = false
    @State private var showingMenu = false
    @State private var showingHourglassSettings = false
    
    // Timer for updating hourglass
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var filteredVideos: [Video] {
        if selectedCategory == "All" {
            return contentStore.videos
        } else {
            return contentStore.videos.filter { $0.category == selectedCategory }
        }
    }
    
    var filteredPhotos: [Photo] {
        if selectedCategory == "All" {
            return contentStore.photos
        } else {
            return contentStore.photos.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Watch time indicator (only for videos)
                if selectedContentType == .videos && (contentStore.parentalControlsEnabled || contentStore.isHourglassActive) {
                    VStack(spacing: 8) {
                        if contentStore.parentalControlsEnabled {
                            WatchTimeIndicator(contentStore: contentStore)
                        }
                        if contentStore.isHourglassActive {
                            HourglassIndicator(contentStore: contentStore)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Loading/Error State
                if contentStore.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading content...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(contentStore.categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Error message if any
                    if let errorMessage = contentStore.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Content grid based on selected type
                    if selectedContentType == .videos {
                        VideoGridView(videos: filteredVideos, contentStore: contentStore)
                    } else {
                        PhotoGridView(photos: filteredPhotos)
                    }
                }
            }
            .navigationTitle(selectedContentType == .videos ? "🎥 Abhi's Edu TV" : "📸 Abhi's Edu Photos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        contentStore.refreshContent()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(contentStore.isLoading)
                }
            }
            .sheet(isPresented: $showingMenu) {
                HamburgerMenuView(
                    selectedContentType: $selectedContentType,
                    showingParentalControls: $showingParentalControls,
                    showingHourglassSettings: $showingHourglassSettings,
                    contentStore: contentStore,
                    onDismiss: { showingMenu = false }
                )
            }
            .sheet(isPresented: $showingParentalControls) {
                ParentalControlsView(contentStore: contentStore)
            }
            .sheet(isPresented: $showingHourglassSettings) {
                HourglassSettingsView(contentStore: contentStore)
            }
            .onReceive(timer) { _ in
                if contentStore.isHourglassActive {
                    contentStore.updateHourglassTimer()
                }
            }
            .refreshable {
                contentStore.refreshContent()
            }
        }
    }
}

// MARK: - Hamburger Menu View
struct HamburgerMenuView: View {
    @Binding var selectedContentType: ContentType
    @Binding var showingParentalControls: Bool
    @Binding var showingHourglassSettings: Bool
    @ObservedObject var contentStore: ContentStore
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Abhi's Edu App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Safe learning for kids")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.all, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                
                // Menu Items
                VStack(spacing: 0) {
                    // Content Type Tabs
                    VStack(alignment: .leading, spacing: 0) {
                        Text("CONTENT")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 8)
                        
                        ForEach(ContentType.allCases, id: \.self) { contentType in
                            MenuRow(
                                icon: contentType.icon,
                                title: contentType.rawValue,
                                isSelected: selectedContentType == contentType
                            ) {
                                selectedContentType = contentType
                                onDismiss()
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Settings and Controls
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SETTINGS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        
                        MenuRow(
                            icon: "gearshape.fill",
                            title: "Parental Controls"
                        ) {
                            showingParentalControls = true
                            onDismiss()
                        }
                        
                        MenuRow(
                            icon: "hourglass",
                            title: "Hourglass Timer"
                        ) {
                            showingHourglassSettings = true
                            onDismiss()
                        }
                        
                        MenuRow(
                            icon: "arrow.clockwise",
                            title: "Refresh Content"
                        ) {
                            contentStore.refreshContent()
                            onDismiss()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 0) {
                        Text("STATS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        
                        MenuStatRow(
                            icon: "play.rectangle.fill",
                            title: "Videos",
                            value: "\(contentStore.videos.count)"
                        )
                        
                        MenuStatRow(
                            icon: "photo.fill",
                            title: "Photos",
                            value: "\(contentStore.photos.count)"
                        )
                        
                        if contentStore.parentalControlsEnabled {
                            MenuStatRow(
                                icon: "clock.fill",
                                title: "Watch Time Today",
                                value: formatTime(contentStore.watchTime)
                            )
                        }
                        
                        if contentStore.isHourglassActive {
                            MenuStatRow(
                                icon: "hourglass",
                                title: "Session Timer",
                                value: formatTime(contentStore.hourglassTimer)
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: 4) {
                    Text("Version 1.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Made with ❤️ for kids")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Menu Stat Row
struct MenuStatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Video Grid View
struct VideoGridView: View {
    let videos: [Video]
    @ObservedObject var contentStore: ContentStore
    
    var body: some View {
        if videos.isEmpty {
            VStack {
                Image(systemName: "video.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("No videos available")
                    .font(.headline)
                    .foregroundColor(.gray)
                Button("Try Again") {
                    contentStore.refreshContent()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(videos) { video in
                        NavigationLink(destination: VideoPlayerView(video: video, contentStore: contentStore)) {
                            VideoThumbnailCard(video: video)
                        }
                        .disabled(!contentStore.canWatchMore)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Photo Grid View
struct PhotoGridView: View {
    let photos: [Photo]
    
    var body: some View {
        if photos.isEmpty {
            VStack {
                Image(systemName: "photo.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("No photos available")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(photos) { photo in
                        NavigationLink(destination: PhotoDetailView(photo: photo)) {
                            PhotoThumbnailCard(photo: photo)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Hourglass Indicator
struct HourglassIndicator: View {
    @ObservedObject var contentStore: ContentStore
    
    var progress: Double {
        guard contentStore.hourglassLimit > 0 else { return 0 }
        return min(contentStore.hourglassTimer / contentStore.hourglassLimit, 1.0)
    }
    
    var body: some View {
        HStack {
            // Custom Hourglass Visual
            HourglassView(progress: progress, isActive: contentStore.isHourglassActive)
                .frame(width: 30, height: 36)
            
            Text("Session: \(formatTime(contentStore.hourglassTimer)) / \(formatTime(contentStore.hourglassLimit))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if contentStore.hourglassTimer >= contentStore.hourglassLimit {
                Text("Session Complete!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            } else if contentStore.isHourglassActive {
                Text("\(formatTime(contentStore.hourglassRemainingTime)) left")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Custom Hourglass View
struct HourglassView: View {
    let progress: Double
    let isActive: Bool
    
    var body: some View {
        ZStack {
            // Hourglass Frame
            Path { path in
                // Top bulb
                path.move(to: CGPoint(x: 5, y: 2))
                path.addLine(to: CGPoint(x: 25, y: 2))
                path.addLine(to: CGPoint(x: 22, y: 5))
                path.addLine(to: CGPoint(x: 8, y: 5))
                path.closeSubpath()
                
                // Bottom bulb
                path.move(to: CGPoint(x: 8, y: 31))
                path.addLine(to: CGPoint(x: 22, y: 31))
                path.addLine(to: CGPoint(x: 25, y: 34))
                path.addLine(to: CGPoint(x: 5, y: 34))
                path.closeSubpath()
                
                // Glass outline
                path.move(to: CGPoint(x: 8, y: 5))
                path.addLine(to: CGPoint(x: 22, y: 5))
                path.addLine(to: CGPoint(x: 15, y: 18))
                path.addLine(to: CGPoint(x: 22, y: 31))
                path.addLine(to: CGPoint(x: 8, y: 31))
                path.addLine(to: CGPoint(x: 15, y: 18))
                path.closeSubpath()
            }
            .stroke(Color.brown, lineWidth: 2)
            
            // Top sand (remaining)
            if progress < 1.0 {
                Path { path in
                    let topHeight = 13 * (1.0 - progress)
                    let topY = 5 + (13 - topHeight)
                    let topWidth = 14 - (6 * (progress))
                    let centerX: CGFloat = 15
                    
                    path.move(to: CGPoint(x: centerX - topWidth/2, y: topY))
                    path.addLine(to: CGPoint(x: centerX + topWidth/2, y: topY))
                    path.addLine(to: CGPoint(x: centerX, y: 18))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Bottom sand (elapsed)
            if progress > 0 {
                Path { path in
                    let bottomHeight = 13 * progress
                    let bottomY = 31 - bottomHeight
                    let bottomWidth = 6 + (8 * progress)
                    let centerX: CGFloat = 15
                    
                    path.move(to: CGPoint(x: centerX - bottomWidth/2, y: 31))
                    path.addLine(to: CGPoint(x: centerX + bottomWidth/2, y: 31))
                    path.addLine(to: CGPoint(x: centerX, y: bottomY))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            
            // Falling sand particles (when active)
            if isActive && progress < 1.0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.orange.opacity(0.6))
                            .frame(width: 2, height: 2)
                            .offset(x: -1, y: 0)
                        
                        Circle()
                            .fill(Color.yellow.opacity(0.4))
                            .frame(width: 1.5, height: 1.5)
                        
                        Circle()
                            .fill(Color.orange.opacity(0.5))
                            .frame(width: 1, height: 1)
                            .offset(x: 1, y: -1)
                        
                        Spacer()
                    }
                    Spacer()
                }
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: false),
                    value: isActive
                )
            }
            
            // Glass reflection
            Path { path in
                path.move(to: CGPoint(x: 9, y: 7))
                path.addLine(to: CGPoint(x: 11, y: 9))
                path.addLine(to: CGPoint(x: 11, y: 15))
                path.addLine(to: CGPoint(x: 9, y: 17))
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isActive)
    }
}

// MARK: - Hourglass Settings View
struct HourglassSettingsView: View {
    @ObservedObject var contentStore: ContentStore
    @Environment(\.presentationMode) var presentationMode
    @State private var tempHourglassLimit: Double
    
    init(contentStore: ContentStore) {
        self.contentStore = contentStore
        self._tempHourglassLimit = State(initialValue: contentStore.hourglassLimit / 60.0) // Convert to minutes
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hourglass Timer")) {
                    HStack {
                        HourglassView(progress: 0.3, isActive: false)
                            .frame(width: 30, height: 36)
                        
                        VStack(alignment: .leading) {
                            Text("Session Timer")
                                .font(.headline)
                            Text("Set a timer for focused screen time sessions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Timer Settings") {
                    VStack(alignment: .leading) {
                        Text("Session Duration: \(Int(tempHourglassLimit)) minutes")
                            .font(.subheadline)
                        
                        Slider(value: $tempHourglassLimit, in: 5...60, step: 5)
                            .accentColor(.purple)
                    }
                    
                    HStack {
                        Text("Current Session:")
                        Spacer()
                        if contentStore.isHourglassActive {
                            Text(formatTime(contentStore.hourglassTimer))
                                .foregroundColor(.purple)
                                .fontWeight(.medium)
                        } else {
                            Text("Not started")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Timer Controls") {
                    if !contentStore.isHourglassActive {
                        Button(action: {
                            contentStore.hourglassLimit = tempHourglassLimit * 60.0
                            contentStore.startHourglassTimer()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Session Timer")
                            }
                            .foregroundColor(.green)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Button(action: {
                                contentStore.resetHourglassTimer()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Reset Timer")
                                }
                                .foregroundColor(.orange)
                            }
                            
                            Button(action: {
                                contentStore.stopHourglassTimer()
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Stop Timer")
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("How It Works") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.purple)
                            Text("Set your desired session length")
                        }
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.purple)
                            Text("Start the timer for focused screen time")
                        }
                        
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.purple)
                            Text("When time's up, take a break!")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Hourglass Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        contentStore.hourglassLimit = tempHourglassLimit * 60.0
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Watch Time Indicator
struct WatchTimeIndicator: View {
    @ObservedObject var contentStore: ContentStore
    
    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
            
            Text("Watch Time Today: \(formatTime(contentStore.watchTime)) / \(formatTime(contentStore.dailyWatchLimit))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !contentStore.canWatchMore {
                Text("Time's Up!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(25)
        }
    }
}

// MARK: - Video Thumbnail Card
struct VideoThumbnailCard: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .shadow(radius: 5)
                    )
            }
            .frame(height: 120)
            .cornerRadius(12)
            .clipped()
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(video.duration)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                    }
                }
            )
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(video.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(video.ageRating)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Photo Thumbnail Card
struct PhotoThumbnailCard: View {
    let photo: Photo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo thumbnail
            AsyncImage(url: URL(string: photo.thumbnailURL ?? photo.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .cornerRadius(12)
            .clipped()
            
            // Photo info
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(photo.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(photo.ageRating)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let video: Video
    @ObservedObject var contentStore: ContentStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showingTimeUp = false
    @State private var watchStartTime = Date()
    
    var body: some View {
        VStack {
            if contentStore.canWatchMore {
                YouTubePlayerView(videoID: video.youtubeID)
                    .frame(height: 250)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(video.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(video.category, systemImage: "tag.fill")
                        Spacer()
                        Label(video.ageRating, systemImage: "person.fill")
                        Spacer()
                        Label(video.duration, systemImage: "clock.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if contentStore.parentalControlsEnabled {
                        Text("Remaining time today: \(formatTime(contentStore.remainingTime))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                Spacer()
            } else {
                TimeUpView {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            watchStartTime = Date()
        }
        .onDisappear {
            let watchDuration = Date().timeIntervalSince(watchStartTime)
            contentStore.addWatchTime(watchDuration)
        }
        .alert("Time's Up!", isPresented: $showingTimeUp) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You've reached your daily watch limit. Come back tomorrow!")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: Photo
    @Environment(\.presentationMode) var presentationMode
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Photo viewer
            AsyncImage(url: URL(string: photo.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    imageScale = max(1.0, min(value, 3.0))
                                },
                            DragGesture()
                                .onChanged { value in
                                    imageOffset = value.translation
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        imageOffset = .zero
                                        imageScale = 1.0
                                    }
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            imageScale = imageScale == 1.0 ? 2.0 : 1.0
                            imageOffset = .zero
                        }
                    }
                    .onTapGesture {
                        showingFullScreen = true
                    }
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        ProgressView()
                    )
            }
            .cornerRadius(12)
            .clipped()
            
            // Photo information
            VStack(alignment: .leading, spacing: 12) {
                Text(photo.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Label(photo.category, systemImage: "tag.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Label(photo.ageRating, systemImage: "person.fill")
                        .foregroundColor(.blue)
                }
                .font(.caption)
                
                if let description = photo.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Text("💡 Tap to view fullscreen • Double-tap to zoom • Pinch to zoom")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenPhotoView(photo: photo)
        }
    }
}

// MARK: - Full Screen Photo View
struct FullScreenPhotoView: View {
    let photo: Photo
    @Environment(\.presentationMode) var presentationMode
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: photo.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    imageScale = max(0.5, min(value, 5.0))
                                },
                            DragGesture()
                                .onChanged { value in
                                    imageOffset = value.translation
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            imageScale = imageScale == 1.0 ? 2.0 : 1.0
                            imageOffset = .zero
                        }
                    }
            } placeholder: {
                ProgressView()
                    .tint(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding()
                
                Spacer()
                
                // Photo title at bottom
                VStack {
                    Text(photo.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onTapGesture {
            withAnimation {
                imageScale = 1.0
                imageOffset = .zero
            }
        }
    }
}

// MARK: - YouTube Player View
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = UIColor.black
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !videoID.isEmpty else { return }
        
        let embedHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        background-color: #000;
                        overflow: hidden;
                    }
                    .video-container {
                        position: relative;
                        width: 100vw;
                        height: 100vh;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                    }
                    iframe {
                        width: 100%;
                        height: 100%;
                        border: none;
                    }
                </style>
            </head>
            <body>
                <div class="video-container">
                    <iframe 
                        src="https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1&controls=1&showinfo=0&fs=1&cc_load_policy=0&iv_load_policy=3&autohide=1"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                        allowfullscreen>
                    </iframe>
                </div>
                <script>
                    // Handle iframe load errors
                    window.addEventListener('message', function(event) {
                        console.log('Message received:', event.data);
                    });
                    
                    // Prevent scrolling
                    document.body.addEventListener('touchmove', function(e) {
                        e.preventDefault();
                    }, { passive: false });
                </script>
            </body>
            </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube.com"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Allow YouTube embed URLs
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("youtube.com") || url.absoluteString.contains("ytimg.com") || url.absoluteString.contains("googlevideo.com") {
                    decisionHandler(.allow)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

// MARK: - Time Up View
struct TimeUpView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "clock.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Time's Up!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've watched enough videos for today. Come back tomorrow for more fun!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onDismiss) {
                Text("OK")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}

// MARK: - Parental Controls View
struct ParentalControlsView: View {
    @ObservedObject var contentStore: ContentStore
    @Environment(\.presentationMode) var presentationMode
    @State private var tempWatchLimit: Double
    
    init(contentStore: ContentStore) {
        self.contentStore = contentStore
        self._tempWatchLimit = State(initialValue: contentStore.dailyWatchLimit / 60.0) // Convert to minutes
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Watch Time Controls") {
                    Toggle("Enable Parental Controls", isOn: $contentStore.parentalControlsEnabled)
                    
                    if contentStore.parentalControlsEnabled {
                        VStack(alignment: .leading) {
                            Text("Daily Watch Limit: \(Int(tempWatchLimit)) minutes")
                                .font(.subheadline)
                            
                            Slider(value: $tempWatchLimit, in: 15...120, step: 15)
                                .accentColor(.blue)
                        }
                        
                        HStack {
                            Text("Today's Watch Time:")
                            Spacer()
                            Text(formatTime(contentStore.watchTime))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Content Info") {
                    HStack {
                        Text("Videos:")
                        Spacer()
                        Text("\(contentStore.videos.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Photos:")
                        Spacer()
                        Text("\(contentStore.photos.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastUpdated = contentStore.lastUpdated {
                        HStack {
                            Text("Last Updated:")
                            Spacer()
                            Text(DateFormatter.shortDateTime.string(from: lastUpdated))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Actions") {
                    Button("Reset Daily Watch Time") {
                        contentStore.resetDailyWatchTime()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Refresh Content") {
                        contentStore.refreshContent()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                Section("About") {
                    Text("This app provides a safe environment for children to watch curated videos and view educational photos.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Parental Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        contentStore.dailyWatchLimit = tempWatchLimit * 60.0 // Convert back to seconds
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
