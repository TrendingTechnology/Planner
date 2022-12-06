//
//  ReminderList.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

struct ReminderList: View {
    
    @EnvironmentObject private var settingManager: SettingManager
    @EnvironmentObject private var vm: CalendarViewModel
    
    var body: some View {
        NavigationView {
            
            mainContent
                .task {
                    if let day = vm.selectedDay, !vm.remindersOnTheScreen.compactMap({ $0.tagId }).filter({ !settingManager.settings.tags.map({ $0.id }).contains($0) }).isEmpty {

                        vm.remindersOnTheScreen = vm.remindersOnTheScreen.map({ reminder in
                            if let tagId = reminder.tagId, !settingManager.settings.tags.map({ $0.id }).contains(tagId) {
                                var newReminder = reminder
                                newReminder.tagId = nil
                                return newReminder
                            }
                            return reminder
                        })
                        await RemindersFromUserDefaultsManager.instance.set(vm.remindersOnTheScreen, for: day)
                    }
                }
                .toolbar { getToolbar() }
                .navigationTitle("Reminders (\(vm.remindersOnTheScreen.count))")
                .navigationBarTitleDisplayMode(.inline)
                .background(settingManager.settings.backgroundColor)
        }
    }
    
    
    @ViewBuilder
    private var mainContent: some View {
        if !vm.remindersOnTheScreen.isEmpty {
            List {
                ForEach(vm.remindersOnTheScreen) { reminder in
                    ReminderRowView(reminder: reminder)
                }
                .onDelete { indexSet in
                    vm.delete(in: indexSet)
                }
                .onMove { indexSet, index in
                    vm.moveReminder(fromOffsets: indexSet, toOffset: index)
                }
                .listRowBackground(settingManager.settings.backgroundColor)
            }
            .scrollDismissesKeyboard(.interactively)
            .listStyle(.plain)
        } else {
            Text("You have no reminders.\nTap '+' button to create one ")
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 30)
        }
    }

    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                vm.createNewReminder()
            } label: {
                Image(systemName: "plus")
            }

            if !vm.remindersOnTheScreen.isEmpty {
                EditButton()
            }
        }
    }
}








struct ReminderList_Previews: PreviewProvider {
    static var previews: some View {
        ReminderList()
            .environmentObject(SettingManager())
            .environmentObject(CalendarViewModel())
    }
}
