//
//  ToolbarButton.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/5/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// A square button typically used with a system image in the toolbar.
///
/// These RoundedRect buttons show text and outline in activeColor (.accentColor by default), with the
/// backgroundColor of UIColor.systemBackground. When active, the text and background switch.
public struct ToolbarImageButton<Content: View>: View {
    private let image: Content
    private let systemName: String?
    private let action: ()->Void
    @Binding private var active: Bool
    private let activeColor: Color
    private let onHover: ((Bool)->Void)?
    
    public var body: some View {
        Button(action: action, label: {
            label()
                .frame(width: MarkupEditor.toolbarStyle.buttonHeight(), height: MarkupEditor.toolbarStyle.buttonHeight())
        })
        .onHover { over in onHover?(over) }
        // For MacOS buttons (Optimized Interface for Mac), specifying .contentShape
        // fixes some flaky problems in surrounding SwiftUI views that are presented
        // below this one, altho AFAICT not in ones adjacent horizontally.
        // Ref: https://stackoverflow.com/a/67377002/8968411
        .contentShape(RoundedRectangle(cornerRadius: 3))
        .buttonStyle(ToolbarButtonStyle(active: $active, activeColor: activeColor))
    }

    /// Initialize a button using content. See the extension where Content == EmptyView for the systemName style initialization.
    public init(action: @escaping ()->Void, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor, onHover: ((Bool)->Void)? = nil, @ViewBuilder content: ()->Content) {
        self.systemName = nil
        self.image = content()
        self.action = action
        _active = active
        self.activeColor = activeColor
        self.onHover = onHover
    }
    
    private func label() -> AnyView {
        // Return either the image derived from content or the properly-sized systemName image based on style
        if systemName == nil {
            return AnyView(image)
        } else {
            return AnyView(Image(systemName: systemName!).imageScale(.large))
        }
    }

}

extension ToolbarImageButton where Content == EmptyView {
    
    /// Initialize a button using a systemImage which will override content, even if passed-in. Intended for use without a content block.
    public init(systemName: String, action: @escaping ()->Void, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor, onHover: ((Bool)->Void)? = nil, @ViewBuilder content: ()->Content = { EmptyView() }) {
        self.systemName = systemName
        self.image = content()
        self.action = action
        _active = active
        self.activeColor = activeColor
        self.onHover = onHover
    }
    
}

public struct ToolbarTextButton: View {
    let title: String
    let action: ()->Void
    let width: CGFloat?
    @Binding var active: Bool
    let activeColor: Color
    
    public var body: some View {
        Button(action: action, label: {
            Text(title)
                .frame(width: width, height: MarkupEditor.toolbarStyle.buttonHeight())
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(
                        cornerRadius: 3,
                        style: .continuous
                    )
                    .stroke(Color.accentColor)
                    .background(Color(UIColor.systemGray6))
                )
        })
        .contentShape(RoundedRectangle(cornerRadius: 3))
        .buttonStyle(ToolbarButtonStyle(active: $active, activeColor: activeColor))
    }
    
    public init(title: String, action: @escaping ()->Void, width: CGFloat? = nil, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor) {
        self.title = title
        self.action = action
        self.width = width
        _active = active
        self.activeColor = activeColor
    }
    
}

public struct ToolbarColorButton: View {
    private let systemName: String?
    private let action: (String)->Void
    private let activeColor: Color
    private let onHover: ((Bool)->Void)?
    @State private var showingColorPicker = false
    @State private var selectedColor = "#000000"
    
    private let colorOptions = [
        ("#000000", "Black"),
        ("#FF0000", "Red"),
        ("#00FF00", "Green"),
        ("#0000FF", "Blue"),
        ("#FFFF00", "Yellow"),
        ("#FF00FF", "Magenta"),
        ("#00FFFF", "Cyan"),
        ("#FFA500", "Orange"),
    ]
    
    public var body: some View {
        Menu {
            ForEach(colorOptions, id: \.0) { color, name in
                Button(action: {
                    selectedColor = color
                    action(color)
                }) {
                    HStack {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 16, height: 16)
                        Text(name)
                    }
                }
            }
        } label: {
            Image(systemName: systemName ?? "textformat")
                .frame(width: MarkupEditor.toolbarStyle.buttonHeight(), height: MarkupEditor.toolbarStyle.buttonHeight())
        }
        .onHover { over in onHover?(over) }
        .contentShape(RoundedRectangle(cornerRadius: 3))
    }
    
    public init(systemName: String? = nil, action: @escaping (String)->Void, activeColor: Color = .accentColor, onHover: ((Bool)->Void)? = nil) {
        self.systemName = systemName
        self.action = action
        self.activeColor = activeColor
        self.onHover = onHover
    }
}

public struct ToolbarButtonStyle: ButtonStyle {
    @Binding var active: Bool
    let activeColor: Color
    
    public init(active: Binding<Bool>, activeColor: Color) {
        _active = active
        self.activeColor = activeColor
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .cornerRadius(3)
            .foregroundColor(active ? Color(UIColor.systemBackground) : activeColor)
            .overlay(
                RoundedRectangle(
                    cornerRadius: 3,
                    style: .continuous
                )
                .stroke(Color.accentColor)
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 3,
                    style: .continuous
                )
                .fill(active ? activeColor: Color.clear)
            )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
