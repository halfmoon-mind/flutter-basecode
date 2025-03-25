import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template/home/cubit/counter_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Home'),
          Text('${context.read<CounterCubit>().state}'),
          ElevatedButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Text('Increment'),
          ),
          ElevatedButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Text('Decrement'),
          ),
        ],
      ),
    );
  }
}
