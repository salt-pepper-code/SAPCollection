//
//  Namespace.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

public enum Component {
    public enum View { }
    public enum Skin {
        public enum Button { }
        public enum PageControl { }
        public enum Switch { }
        public enum Slider { }
        public enum SliderRange { }
        public enum TabBar { }
        public enum TabBarItem { }
    }
}

extension Component {
    public enum Direction {
        case vertical
        case horizontal
    }
}
